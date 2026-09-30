# Robot Framework API Case Reporter

One standalone HTML evidence report per Robot Framework test case. Supports
RequestsLibrary responses, multiple HTTP requests, business assertions, metadata,
JSON formatting, request/response headers, Table/Raw and Copy.

Version 0.1.0 targets Python 3.12+ and Robot Framework 7.5+. No pytest adapter.

## Install

```bash
pip install robotframework_api_case_reporter-0.1.0-py3-none-any.whl
```

The package is not yet published on PyPI. Download the WHL from CI artifacts or a
GitHub release once available. RequestsLibrary is installed separately.

```robotframework
*** Settings ***
Library    RequestsLibrary
Library    APICaseReporter    WITH NAME    Report

*** Test Cases ***
Example
    ${response}=    GET    ${BASE_URL}/health    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Health    ${response}
    Report.Check    ${id}    HTTP status
    ...    Should Be Equal As Integers    ${response.status_code}    200
```

The library registers its listener automatically and writes into Robot's
`OUTPUT DIR/cases`. No separate listener option or generation keyword is needed.
Each report contains only one test case and works offline.

## Development

```bash
poetry install
poetry run ruff check .
poetry run ruff format --check .
poetry run mypy src
poetry run python scripts/verify.py
poetry build
poetry run python scripts/build_site.py
```

Acceptance tests use Robot Framework and a loopback HTTP fixture. Some cases
intentionally fail; scripts/verify.py checks their exact results instead of
ignoring the Robot exit code. No live credentials or external endpoints are used.

Documentation: https://angel-valdezzz.github.io/robotframework-api-case-reporter/

Libdoc: the same site under `/keywords/`. Live example under `/examples/report.html`.

## Scope and limitations

- Metadata is optional. Name, status and duration come from Robot.
- Only English UI is currently supported; business labels may use any language.
- Configured JSON/form/query fields and headers are redacted in this reporter's HTML.
  Robot and RequestsLibrary logs have their own independent logging behavior.
- Binary responses and multipart uploads are summarized, not embedded.
- HTTP transport errors without a Response appear in the final case error, with no
  fabricated request. Keys missing before Check executes appear as Robot errors.
- Pabot processes are supported with distinct output directories per worker. Sharing
  one physical report directory across concurrent writers is not supported in 0.1.
- Integration of the separate example repository and PyPI registration are deferred.

See the documentation for release workflow and Trusted Publisher configuration.
