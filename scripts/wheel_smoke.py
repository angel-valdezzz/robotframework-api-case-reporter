"""Install the built WHL in a clean environment and run Robot acceptance tests."""

import subprocess
import sys
import tempfile
import tomllib
import venv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    version = tomllib.loads((ROOT / "pyproject.toml").read_text(encoding="utf-8"))["project"][
        "version"
    ]
    wheel = ROOT / "dist" / f"robotframework_request_reporter-{version}-py3-none-any.whl"
    with tempfile.TemporaryDirectory(prefix="api-reporter-wheel-") as directory:
        environment = Path(directory) / "venv"
        venv.EnvBuilder(with_pip=True).create(environment)
        python = environment / ("Scripts/python.exe" if sys.platform == "win32" else "bin/python")
        subprocess.run(
            [
                str(python),
                "-m",
                "pip",
                "install",
                str(wheel),
                "robotframework-requests==0.9.7",
                "robotframework-datadriver==1.11.2",
            ],
            check=True,
        )
        subprocess.run([str(python), str(ROOT / "scripts" / "verify.py")], cwd=ROOT, check=True)
    print("WHL installed and accepted in a clean environment.")


if __name__ == "__main__":
    main()
