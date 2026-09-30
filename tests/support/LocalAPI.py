"""A loopback-only HTTP fixture and report assertions for Robot acceptance tests."""

import json
import re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Thread
from typing import Any

from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn


@library(scope="SUITE")
class LocalAPI:
    def __init__(self) -> None:
        self.server: ThreadingHTTPServer | None = None
        self.thread: Thread | None = None

    @keyword
    def start_api(self) -> str:
        class Handler(BaseHTTPRequestHandler):
            def log_message(self, *args: Any) -> None:
                pass

            def send(
                self, status: int, payload: Any, content_type: str = "application/json"
            ) -> None:
                body = payload if isinstance(payload, bytes) else json.dumps(payload).encode()
                self.send_response(status)
                self.send_header("Content-Type", content_type)
                self.send_header("X-Test", "fixture")
                self.end_headers()
                self.wfile.write(body)

            def do_POST(self) -> None:
                self.rfile.read(int(self.headers.get("Content-Length", "0")))
                self.send(200, {"access_token": "fixture-token-SECRET", "token_type": "Bearer"})

            def do_GET(self) -> None:
                path = self.path.split("?", 1)[0]
                if path == "/broken":
                    self.send(502, b"upstream unavailable", "text/plain")
                elif path == "/non-json":
                    self.send(200, b"not a JSON object", "application/json")
                elif path == "/binary":
                    self.send(200, b"\x00\xff\x01", "application/octet-stream")
                elif path == "/hostile":
                    self.send(200, {"text": '</script><script>alert("unsafe")</script>'})
                else:
                    failed = path.endswith("1087")
                    self.send(
                        200,
                        {
                            "id": 1087 if failed else 1042,
                            "tipoDistribuidor": "DIRECTO" if failed else "AGENTE",
                            "tipoPersona": "FISICA",
                            "rfc": "" if failed else "AAAA900101AB1",
                            "curp": "AAAA900101HDFXXX01",
                        },
                    )

        self.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        self.thread = Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        return f"http://127.0.0.1:{self.server.server_port}"

    @keyword
    def stop_api(self) -> None:
        if self.server:
            self.server.shutdown()
            self.server.server_close()
        if self.thread:
            self.thread.join(timeout=5)

    @keyword
    def inspect_case(self, name: str, requests: int, passed: int, failed: int, status: str) -> None:
        directory = Path(BuiltIn().get_variable_value("${OUTPUT DIR}")) / "cases"
        found = [p for p in directory.glob("*.html") if self.payload(p)["name"] == name]
        assert found, f"Report not found for {name}"
        payload = self.payload(found[-1])
        validations = [v for r in payload["exchanges"] for v in r["validations"]]
        assert len(payload["exchanges"]) == requests
        assert sum(v["status"] == "PASS" for v in validations) == passed
        assert sum(v["status"] == "FAIL" for v in validations) == failed
        assert payload["status"] == status, payload["message"]
        raw = found[-1].read_text()
        for secret in ["fixture-token-SECRET", "fixture-secret-SECRET", "query-secret-SECRET"]:
            assert secret not in raw, f"Secret leaked: {secret}"

    @staticmethod
    def payload(path: Path) -> dict[str, Any]:
        match = re.search(
            r'<script type="application/json" id="case-data">(.*?)</script>',
            path.read_text(),
            re.DOTALL,
        )
        assert match
        return json.loads(match[1])
