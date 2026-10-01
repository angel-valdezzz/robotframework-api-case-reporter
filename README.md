# Robot Framework Robot Framework Request Reporter

One standalone HTML evidence report per Robot Framework test case. Supports
RequestsLibrary responses, multiple HTTP requests, business assertions, metadata,
JSON formatting, request/response headers, Table/JSON and Copy.

Version 0.3.0 targets Python 3.12+ and Robot Framework 7.5+. No pytest adapter.

## Install

```bash
pip install robotframework-request-reporter==0.3.0
pip install robotframework-requests
```

RequestsLibrary is installed separately. The WHL can also be downloaded from PyPI.

[Manual de usuario](https://angel-valdezzz.github.io/robotframework-request-reporter/) ·
[Referencia de keywords](https://angel-valdezzz.github.io/robotframework-request-reporter/keywords/) ·
[Ejemplo en vivo](https://angel-valdezzz.github.io/robotframework-request-reporter/examples/report.html) ·
[Paquete en PyPI](https://pypi.org/project/robotframework-request-reporter/) ·
[Ejemplo ejecutable](https://github.com/angel-valdezzz/robotframework-api-testing/tree/main)

```robotframework
*** Settings ***
Library    RequestsLibrary
Library    RequestReporter    

*** Test Cases ***
Example
    ${response}=    GET    ${BASE_URL}/health    expected_status=anything
    ${id}=    Capture Response    Health    ${response}
    Assert    ${id}    HTTP status
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

## Scope and limitations

- Metadata is optional. Name, status and duration come from Robot.
- Only English UI is currently supported; business labels may use any language.
- Configured JSON/form/query fields and headers are redacted in this reporter's HTML.
  Robot and RequestsLibrary logs have their own independent logging behavior.
- Binary responses and multipart uploads are summarized, not embedded.
- HTTP transport errors without a Response appear in the final case error, with no
  fabricated request. Keys missing before Assert executes appear as Robot errors.
- Pabot processes are supported with distinct output directories per worker. Sharing
  one physical report directory across concurrent writers is not supported in 0.2.
- Light/Dark control follows the system initially and remembers your choice when storage is available.
- PASS, FAIL and SKIP use green, red and amber with distinct shades in both themes.

See the documentation for release workflow and Trusted Publisher configuration.

Headers can be viewed as formatted JSON and copied with the copy icon. The clipboard
and manual fallback both contain indented JSON with configured secrets masked.

The report opens on Summary with request/assertion counters, a readable UTC date
and case duration. Failures links each failed assertion to its request. Execution
errors outside Assert are recorded automatically; handled keyword failures are excluded.
HTTP status colors describe the response class independently of PASS/FAIL assertions.

Changes are integrated into main through pull requests with required CI checks.

## Migration from APICaseReporter

Install `robotframework-request-reporter` and import `RequestReporter`. Do not install both distributions: the new wheel includes the legacy import. `Capture HTTP Exchange` and `Check` remain compatibility aliases; new suites use `Capture Response` and `Assert`. These keywords record an existing response and execute an assertion respectively; capturing does not send another request.
