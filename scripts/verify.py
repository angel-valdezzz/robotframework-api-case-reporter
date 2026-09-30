"""Run Robot acceptance tests and verify intentional failures and report isolation."""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

from robot.api import ExecutionResult

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    output = ROOT / "results" / "acceptance"
    if output.exists():
        shutil.rmtree(output)
    process = subprocess.run(
        [sys.executable, "-m", "robot", "--outputdir", str(output), str(ROOT / "tests")],
        cwd=ROOT,
        check=False,
    )
    result = ExecutionResult(str(output / "output.xml"))
    tests = [test for suite in result.suite.suites for test in suite.tests]
    assert len(tests) == 17, f"Expected 17 cases, got {len(tests)}"
    for test in tests:
        if "expected-failure" in test.tags:
            assert test.status == "FAIL", f"Expected intentional failure: {test.name}"
        elif test.name == "Skipped case":
            assert test.status == "SKIP"
        else:
            assert test.status == "PASS", f"{test.name}: {test.message}"
    assert all(s.teardown.status == "PASS" for s in result.suite.suites)
    assert process.returncode == 6, f"Unexpected Robot exit code: {process.returncode}"
    reports = list((output / "cases").glob("*.html"))
    assert len(reports) == 17, "One report per test, including duplicate names and SKIP"
    for path in reports:
        html = path.read_text()
        match = re.search(
            r'<script type="application/json" id="case-data">(.*?)</script>', html, re.DOTALL
        )
        assert match, f"Missing report payload: {path}"
        data = json.loads(match[1])
        assert data["status"] != "RUNNING"
        assert "fixture-token-SECRET" not in html
        assert "fixture-secret-SECRET" not in html
        assert "query-secret-SECRET" not in html
        assert '<script>alert("unsafe")</script>' not in html
        errors = data["execution_errors"]
        if data["name"] in {"Failing distributor", "Empty fields", "Handled error"}:
            assert not errors, f"Assertions/handled failures duplicated: {data['name']}"
        if data["name"] == "Invalid JSON stops parsing":
            assert len(errors) == 1 and "JSON" in errors[0]["message"]
        if data["name"] == "Timeout without response":
            assert len(errors) == 1 and not data["exchanges"]
            assert "Timeout" in errors[0]["message"] or "timed out" in errors[0]["message"]
        if data["name"] == "Handled error then unhandled error":
            assert len(errors) == 1
            assert errors[0]["message"] == "Unhandled failure must appear"
    failing = next(p for p in reports if p.name == "Failing_distributor.html")
    demo = ROOT / "build" / "report.html"
    demo.parent.mkdir(exist_ok=True)
    shutil.copyfile(failing, demo)
    print("Verified 17 Robot cases, assertion/execution errors, DataDriver and redaction.")


if __name__ == "__main__":
    main()
