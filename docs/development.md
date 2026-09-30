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

## Trusted Publishing pendiente

Configurar en la cuenta PyPI del propietario un **pending publisher**:

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

Hasta completar esta configuración, usar el WHL del artefacto de CI. No se ha
publicado el paquete en PyPI ni se requiere compartir una contraseña/token en chat.
