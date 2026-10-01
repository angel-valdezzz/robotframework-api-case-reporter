# Leer el reporte

[Explorar el ejemplo en vivo](examples/report.html){ .md-button .md-button--primary }

## Summary

El encabezado usa el nombre y el estado final del caso de Robot. La fecha se
presenta en UTC, con zona horaria explícita. La duración incluye la ejecución del
caso, setup y teardown del test según los eventos de Robot.

Las cuatro tarjetas muestran requests capturadas, assertions ejecutadas,
aprobadas y fallidas. Los metadatos son opcionales. Si hay fallos, un aviso permite
abrir Failures sin llenar el dashboard con mensajes técnicos.

## Requests y Assertions

Elige una request y consulta **Response**, **Request**, **Headers** o **Assertions**.
Cada assertion tiene su label, keyword, estado y detalles. Las igualdades habituales
muestran Expected/Actual; otras keywords incluyen argumentos y mensaje de error.

| Señal | Interpretación |
|---|---|
| PASS / FAIL / SKIP del encabezado | Estado final del caso de Robot |
| PASS / FAIL de una assertion | Resultado de un `Assert` ejecutado |
| HTTP `2xx`, verde | Respuesta HTTP exitosa |
| HTTP `3xx`, ámbar | Redirección |
| HTTP `4xx` / `5xx`, rojo | Error HTTP del cliente o servidor |
| HTTP `1xx`, azul | Respuesta informativa |

!!! example "Un error HTTP puede ser el resultado esperado"
    Si tu test comprueba que un recurso ausente devuelve `404`, el código HTTP
    tendrá su color de error y la assertion puede ser PASS. Un `200` con datos
    incorrectos también puede terminar en FAIL. Son resultados independientes.

Los métodos GET, POST, PUT, PATCH, DELETE, HEAD y OPTIONS tienen colores propios;
no expresan el resultado del caso. Texto e iconos acompañan los colores.

## Failures

La tabla contiene solo assertions fallidas. Cada fila enlaza a la request y la
assertion exacta. Se genera con los datos capturados por `Assert`; no requiere una
keyword nueva ni repetir información en el `.robot`.

**Execution errors** muestra fallos de keywords fuera de `Assert`, como un timeout,
un error al interpretar JSON o un identificador de request desconocido. Se conservan
el nombre de la keyword y el mensaje de Robot. Fallos manejados por TRY/EXCEPT o
keywords de manejo de errores no se presentan como errores de ejecución sin manejar.

El mensaje final original de Robot permanece desplegable. Puede contener fallos
que ocurren fuera de la ejecución de keywords, por ejemplo al resolver una condición.

!!! note "Lo que no se cuenta"
    Un timeout sin response no fabrica una request. Las assertions que no llegaron
    a ejecutarse no se cuentan como SKIP. SKIP del encabezado corresponde al caso.

## Controles accesibles

Puedes navegar con teclado. Las pestañas de una request aceptan flechas izquierda
/derecha, Home y End. Los enlaces de fallos llevan el foco a la assertion. Ambos
modos de color mantienen labels de estado y controles con nombres accesibles.

## Request y Params

El método y la URL están juntos; el icono junto a la URL copia la dirección ya protegida. HTTP status y duración de la respuesta se muestran debajo. **Params** presenta los query parameters de la URL enviada, incluidas claves repetidas y valores vacíos. La copia usa un array JSON para conservar las repeticiones. Los secretos se ocultan antes de mostrar o copiar los datos.
