# Uso con Robot Framework

```robotframework
*** Settings ***
Library    RequestsLibrary
Library    APICaseReporter    WITH NAME    Report

*** Test Cases ***
Consultar distribuidor
    Report.Set Case Metadata    case_id=DIST-001    environment=QA
    ${response}=    GET    ${BASE_URL}/distribuidores/1042    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Consultar distribuidor    ${response}
    Report.Check    ${id}    Verificar código HTTP
    ...    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    Report.Check    ${id}    Verificar tipo distribuidor
    ...    Should Be Equal As Strings    ${body}[tipoDistribuidor]    AGENTE
```

Ejecutar con `robot --outputdir results tests.robot`. El HTML aparecerá en
`results/cases/Consultar_distribuidor.html`. No se requiere un listener por CLI.

## Varios requests

Registra cada response (incluido el token) y conserva su ID. El ID asocia cada
validación al request correcto; no se usa un “último request” implícito.

## Validaciones independientes

Agrupa las keywords de negocio bajo `[Tags]    robot:continue-on-failure` para
completar sus comprobaciones y mantener FAIL si alguna falla. Los pasos de
adquisición del token y consulta se mantienen fuera de ese grupo.

`Check` admite BuiltIn y keywords propias. Devuelve el retorno normal de la assertion
y propaga sus fallos; no convierte errores en PASS. Igualdad muestra Expected/Actual;
keywords propias muestran sus argumentos y error. La keyword de ejemplo
`Campo Debe Tener Contenido` se reconoce como comprobación de contenido no vacío.

## DataDriver

Cada test generado recibe su propio contexto y HTML. No es obligatorio enviar la
fila del CSV como metadata. Nombres repetidos generan sufijos `_2`, `_3`, etc.

## Errores

Captura el response antes de verificar status o parsear JSON. Un 4xx/5xx o un body
no JSON puede aparecer en el reporte. Un timeout o fallo de transporte sin response
solo aparece en el error del caso. Una clave ausente que impida ejecutar `Check`
aparece como error de Robot, sin sumar una validación que no se ejecutó.

Solo registra intercambios capturados explícitamente. Importar RequestsLibrary no
implica interceptar automáticamente todas sus peticiones.
