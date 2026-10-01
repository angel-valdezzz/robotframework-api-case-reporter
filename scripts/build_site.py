"""Assemble MkDocs, Libdoc and a generated sample into one Pages artifact."""

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    demo = ROOT / "build" / "report.html"
    if not demo.is_file():
        subprocess.run([sys.executable, str(ROOT / "scripts" / "verify.py")], check=True)
    keywords = ROOT / "docs" / "keywords" / "index.html"
    keywords.parent.mkdir(exist_ok=True)
    subprocess.run(
        [sys.executable, "-m", "robot.libdoc", "RequestReporter", str(keywords)],
        cwd=ROOT,
        check=True,
    )
    examples = ROOT / "docs" / "examples"
    examples.mkdir(exist_ok=True)
    shutil.copyfile(demo, examples / "report.html")
    # Remove the retired demo even when rebuilding an existing working directory.
    (examples / "skipped.html").unlink(missing_ok=True)
    shutil.copyfile(
        ROOT / "results/acceptance/cases/Passing_distributor.html", examples / "passing.html"
    )
    subprocess.run([sys.executable, "-m", "mkdocs", "build", "--strict"], cwd=ROOT, check=True)
    print("Built MkDocs, keywords/index.html and examples/report.html.")


if __name__ == "__main__":
    main()
