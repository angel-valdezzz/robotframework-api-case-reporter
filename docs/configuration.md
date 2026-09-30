# Configuración

```robotframework
Library    APICaseReporter
...    output_dir=${OUTPUT DIR}/cases
...    language=en
...    redact_headers=Authorization,Cookie,Set-Cookie,X-API-Key
...    redact_body_fields=access_token,refresh_token,client_secret,password,token,api_key
...    WITH NAME    Report
```

| Parámetro | Comportamiento |
|---|---|
| output_dir | Por defecto, `OUTPUT DIR/cases`. |
| language | Solo `en` en 0.1. Los nombres y labels conservan su idioma. |
| redact_headers | Lista separada por comas, sin distinguir mayúsculas. Reemplaza la lista predeterminada. |
| redact_body_fields | Campos JSON/form/query, incluyendo objetos anidados. Reemplaza la lista predeterminada. |

Headers: Authorization, Proxy-Authorization, Cookie, Set-Cookie y X-API-Key se
ocultan por defecto. También se ocultan valores sensibles ya conocidos en los
mensajes y datos posteriores. Esto no reemplaza una clasificación de datos personales:
agrega a la configuración los nombres sensibles que utilice tu API.

La redacción aplica a **este HTML**. Los logs de Robot y RequestsLibrary son
independientes y pueden contener los argumentos originales.

Responses binarios se resumen con su tamaño. Bodies multipart no se incrustan.
Headers Raw son texto `Nombre: valor`, no los bytes originales de la conexión.
Copy conserva los valores ocultos y ofrece selección manual si clipboard está bloqueado.

Pabot debe usar directorios distintos por worker: escribir concurrentemente en
una misma carpeta no está soportado en 0.1. La integración externa del repositorio
de ejemplos se realizará en una etapa posterior.
