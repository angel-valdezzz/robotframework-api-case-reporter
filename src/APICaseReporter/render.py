"""Render standalone HTML, with a stable JSON payload and no external assets."""

import re
from dataclasses import asdict
from importlib.resources import files
from pathlib import Path

from jinja2 import Environment, select_autoescape

from .models import Case
from .redaction import Redactor


def write_report(case: Case, directory: Path, redactor: Redactor) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    stem = re.sub(r"[^\w.-]+", "_", case.name, flags=re.UNICODE).strip("._")[:130] or "case"
    target = directory / f"{stem}.html"
    counter = 2
    while target.exists():
        target = directory / f"{stem}_{counter}.html"
        counter += 1
    environment = Environment(autoescape=select_autoescape(["html"]))
    template = environment.from_string(
        files("APICaseReporter").joinpath("templates/report.html").read_text(encoding="utf-8")
    )
    # Final cleaning also removes secrets learned in subsequent requests.
    payload = redactor.clean(asdict(case))
    target.write_text(template.render(case=payload), encoding="utf-8")
    return target
