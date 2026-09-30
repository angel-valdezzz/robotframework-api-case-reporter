# Evidencia API, un archivo por caso

<div class="hero" markdown>

**Del test de Robot al archivo que adjuntas en Jira.**

API Case Reporter genera un HTML independiente con las requests, responses y
assertions de cada caso. El nombre y el estado vienen directamente de Robot.
El reporte se abre sin conexión y no necesita un servidor.

[Empezar](installation.md){ .md-button .md-button--primary }
[Ver el reporte](examples/report.html){ .md-button }
[Keywords](keywords/index.html){ .md-button }

</div>

## Qué necesitas

| Herramienta | Compatibilidad |
|---|---|
| Python | 3.12 o superior |
| Robot Framework | 7.5 o superior, rama 7.x |
| RequestsLibrary | Ejecuta las peticiones; se instala aparte |
| DataDriver | Opcional, genera los casos a partir de datos |

## Cómo funciona

```mermaid
flowchart TD
    A[RequestsLibrary: ejecutar petición] --> B[Capture HTTP Exchange: guardar response]
    B --> C[Check: registrar assertions]
    C --> D[Listener: finalizar caso]
    D --> E[HTML independiente para Jira]
```

Solo se incluyen los intercambios que capturas explícitamente. Importar la librería
registra su listener: no necesitas un argumento CLI ni una keyword de generación.

!!! tip "Los metadatos son opcionales"
    Puedes agregar entorno, identificador o fila de datos para dar contexto.
    El reporte funciona sin ellos y sin un título adicional.

## Elige tu recorrido

- **Primer uso:** [instalar](installation.md) y [ejecutar un caso](usage.md).
- **Datos tabulares:** [generar casos con DataDriver](datadriver.md).
- **Revisar resultados:** [leer Summary, Failures y Assertions](report.md).
- **Consultar argumentos:** [referencia Libdoc](keywords/index.html).
- **Probar el proyecto completo:** [ejemplo ejecutable](https://github.com/angel-valdezzz/robot-api-case-report/tree/dev), con Poetry y una API local ficticia.

También puedes abrir un [reporte SKIP](examples/skipped.html). Cada ejemplo es un
archivo de un solo caso. No existe un dashboard que reúna toda la suite.
