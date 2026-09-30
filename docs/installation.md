# Instalación

Requisitos: Python 3.12 o superior y Robot Framework 7.5 o superior.

## Desde PyPI

```bash
python -m pip install robotframework-api-case-reporter==0.1.0 robotframework-requests
# En Poetry:
poetry add robotframework-api-case-reporter==0.1.0 robotframework-requests
```

## Desde WHL

Descarga el archivo de PyPI o del artefacto `distribution` de GitHub Actions:

```bash
python -m pip install robotframework_api_case_reporter-0.1.0-py3-none-any.whl
python -m pip install robotframework-requests
```

También puedes agregar un WHL a tu proyecto Poetry:

```bash
poetry add ./robotframework_api_case_reporter-0.1.0-py3-none-any.whl
```

El WHL incluye el template y los assets del reporte. No necesita MkDocs, Markdown,
Ruff ni las dependencias de desarrollo para ejecutar los tests.

## Desde el repositorio

```bash
git clone https://github.com/angel-valdezzz/robotframework-api-case-reporter.git
cd robotframework-api-case-reporter
git checkout dev
poetry install
poetry build
```

La versión 0.1.0 está publicada en PyPI mediante Trusted Publishing.
No se necesita acceder a PyPI para instalar un WHL previamente descargado.
