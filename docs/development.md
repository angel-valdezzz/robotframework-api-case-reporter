# Desarrollo y publicación

## Calidad y aceptación

```bash
poetry install
poetry run ruff check .
poetry run ruff format --check .
poetry run mypy src
poetry run python scripts/verify.py
poetry build
poetry run twine check dist/*
poetry run python scripts/build_site.py
```

Las pruebas usan Robot Framework, RequestsLibrary y una API en loopback. Cuatro casos
fallan intencionalmente para verificar el estado final y sus evidencias. El verificador
comprueba los resultados esperados y devuelve error si aparecen diferencias.

## Libdoc

La biblioteca declara `doc_format="MARKDOWN"`. Robot 7.5 soporta Markdown en los
docstrings y la referencia se obtiene desde la librería instalada:

```bash
poetry run python -m robot.libdoc APICaseReporter site/keywords/index.html
```

Markdown y Pygments son dependencias de documentación, no de ejecución. Los ejemplos
usan bloques `robotframework`; `[Check]` enlaza una keyword en Libdoc. La importación
no crea archivos ni requiere un test activo, para poder generar la referencia.

## Actions

- `ci.yml`: lint, formato, tipos, suites Robot, construcción y verificación del WHL instalado.
- `pages.yml`: MkDocs, Libdoc y reporte generado; publica las tres rutas juntas.
- `release.yml`: construir distribución y publicar en PyPI desde una release.

Pages usa un sitio por repositorio. Durante la primera etapa se despliega desde `dev`.

## Trusted Publishing

La versión 0.1.0 se publicó mediante Trusted Publishing desde `release.yml`.
Para configurar un publisher equivalente:

| Campo | Valor |
|---|---|
| Project name | robotframework-api-case-reporter |
| GitHub owner | angel-valdezzz |
| Repository | robotframework-api-case-reporter |
| Workflow filename | release.yml |
| Environment name | pypi |

El workflow ya utiliza OIDC y `pypa/gh-action-pypi-publish`, sin tokens guardados.
Configurar el pending publisher no reserva el nombre. La publicación se ejecuta al
publicar una release estable cuyo tag, por ejemplo `v0.1.0`, coincida con pyproject.toml.

El publisher inicial se registró sin restricción de environment (`Any`). El workflow
usa el entorno `pypi`; se puede limitar el publisher a ese entorno.
No se requiere compartir una contraseña ni guardar un API token.

## Ejemplo instalado desde PyPI

El repositorio [robot-api-case-report](https://github.com/angel-valdezzz/robot-api-case-report/tree/dev)
instala la versión publicada, ejecuta una API local ficticia y verifica un caso
individual y dos casos DataDriver. Cada caso genera su propio HTML.
