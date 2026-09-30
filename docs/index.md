# Un reporte por caso

API Case Reporter genera un HTML independiente por test de Robot Framework.
Cada archivo contiene únicamente los requests, responses y validaciones de ese
caso. Puede adjuntarse individualmente a Jira y abrirse sin conexión.

La primera versión integra **Robot Framework 7.5+ y RequestsLibrary**. No requiere
un servidor de reportes y no tiene una integración con pytest.

## Tres vistas

- [Manual de uso](usage.md): cómo instalar y usar la librería.
- [Referencia Libdoc](keywords/index.html): argumentos, ejemplos y errores de cada keyword.
- [Reporte generado](examples/report.html): un caso real de la suite de aceptación
  contra una API ficticia local. Incluye dos requests y dos validaciones fallidas.
  También puedes revisar un [caso SKIP](examples/skipped.html).

## Flujo

1. RequestsLibrary ejecuta la petición.
2. `Capture HTTP Exchange` registra el intercambio y devuelve un ID.
3. `Check` ejecuta una assertion de Robot y registra su resultado en ese request.
4. El listener genera el HTML al terminar el caso, incluyendo su estado final.

Nombre, estado y duración se obtienen automáticamente. Los metadatos son opcionales.
La librería no modifica la política de continuar ante fallos.
