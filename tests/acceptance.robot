*** Settings ***
Library           RequestsLibrary
Library           String
Library           RequestReporter
Library           support/LocalAPI.py

Suite Setup       Start Fixture
Suite Teardown    Verify Reports


*** Test Cases ***
Passing distributor
    ${token}=    Get token
    ${body}    ${id}=    Get distributor    1042    ${token}
    Verify distributor data    ${id}    ${body}

Failing distributor
    [Tags]    expected-failure
    Set Case Metadata    case_id=DIST-002    environment=QA    distribuidor_id=1087
    ${token}=    Get token
    ${body}    ${id}=    Get distributor    1087    ${token}
    Verify distributor data    ${id}    ${body}

Non JSON error response
    ${response}=    GET    ${BASE_URL}/broken    expected_status=anything
    ${id}=    Capture Response    Upstream error    ${response}
    Assert    ${id}    Expected HTTP error    Should Be Equal As Integers    ${response.status_code}    502

Invalid JSON stops parsing
    [Tags]    expected-failure
    ${response}=    GET    ${BASE_URL}/non-json    expected_status=anything
    Capture Response    Invalid JSON    ${response}
    ${body}=    Set Variable    ${response.json()}
    Fail    Should not reach this step

Binary response
    ${response}=    GET    ${BASE_URL}/binary    expected_status=anything
    ${id}=    Capture Response    Binary    ${response}
    Assert    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200

Empty fields
    [Tags]    expected-failure
    ${response}=    GET    ${BASE_URL}/distribuidores/1042    expected_status=anything
    ${id}=    Capture Response    Empty values    ${response}
    Verify empty values    ${id}

Untrusted body content
    ${response}=    GET    ${BASE_URL}/hostile    expected_status=anything
    ${id}=    Capture Response    Untrusted text    ${response}
    Assert    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200

No requests
    Set Case Metadata    case_id=EMPTY
    No Operation

Unknown request ID
    [Tags]    expected-failure
    Assert    unknown    Invalid ID    Should Be Equal    a    a

Skipped case
    Skip    Demonstrate a skipped report

Timeout without response
    [Tags]    expected-failure
    GET    ${BASE_URL}/slow    timeout=0.01    expected_status=anything

Captured timeout without response
    [Tags]    expected-failure
    TRY
        GET    url=${BASE_URL}/slow?api_key=query-secret-SECRET    timeout=0.01    expected_status=anything
    EXCEPT    AS    ${error}
        Capture Request Error    Consulta lenta    GET
        ...    url=${BASE_URL}/slow?api_key=query-secret-SECRET    message=${error}
        Fail    ${error}
    END

CON
    No Operation

Handled error
    TRY
        Fail    Handled failure must not appear as an execution error
    EXCEPT
        No Operation
    END

Handled error then unhandled error
    [Tags]    expected-failure
    TRY
        Fail    Handled failure must not appear as an execution error
    EXCEPT
        No Operation
    END
    Fail    Unhandled failure must appear

# Intentional duplicate names exercise independent report filenames.
# robocop: off=DUP01

Duplicate name
    No Operation

# Intentional duplicate names exercise independent report filenames.
# robocop: off=DUP01

Duplicate name
    No Operation

# robocop: on=DUP01


*** Keywords ***
Start Fixture
    ${url}=    Start API
    Set Suite Variable    ${BASE_URL}    ${url}

Get token
    ${form}=    Create Dictionary    client_secret=fixture-secret-SECRET
    ${response}=    POST    ${BASE_URL}/oauth/token    data=${form}    expected_status=anything
    ${id}=    Capture Response    Obtener token    ${response}
    Assert    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    Assert    ${id}    Token presente    Should Not Be Empty    ${body}[access_token]
    RETURN    ${body}[access_token]

Get distributor
    [Arguments]    ${number}    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET    url=${BASE_URL}/distribuidores/${number}?api_key=query-secret-SECRET&tag=one&tag=two&empty=
    ...    headers=${headers}    expected_status=anything
    ${id}=    Capture Response    Consultar distribuidor    ${response}
    Assert    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    RETURN    ${body}    ${id}

Verify distributor data
    [Tags]    robot:continue-on-failure
    [Arguments]    ${id}    ${body}
    Assert    ${id}    Verificar tipo distribuidor
    ...    Should Be Equal As Strings    ${body}[tipoDistribuidor]    AGENTE
    Assert    ${id}    Verificar tipo persona
    ...    Should Be Equal As Strings    ${body}[tipoPersona]    FISICA
    Assert    ${id}    Verificar RFC no vacío    Campo Debe Tener Contenido    ${body.get('rfc')}
    Assert    ${id}    Verificar CURP no vacía    Campo Debe Tener Contenido    ${body.get('curp')}
    Assert    ${id}    Verificar folio generado    Should Not Be Empty    ${body}[registration][folio]

Campo Debe Tener Contenido
    [Arguments]    ${value}
    Should Not Be Equal    ${value}    ${NONE}
    ${text}=    Convert To String    ${value}
    ${text}=    Strip String    ${text}
    Should Not Be Empty    ${text}

Verify empty values
    [Tags]    robot:continue-on-failure
    [Arguments]    ${id}
    Assert    ${id}    Null    Campo Debe Tener Contenido    ${NONE}
    Assert    ${id}    Empty    Campo Debe Tener Contenido    ${EMPTY}
    Assert    ${id}    Whitespace    Campo Debe Tener Contenido    ${SPACE}${SPACE}

Verify Reports
    Stop API
    Inspect Case    Passing distributor    2    8    0    PASS
    Inspect Case    Failing distributor    2    6    2    FAIL
    Inspect Case    Non JSON error response    1    1    0    PASS
    Inspect Case    Invalid JSON stops parsing    1    0    0    FAIL
    Inspect Case    Binary response    1    1    0    PASS
    Inspect Case    Empty fields    1    0    3    FAIL
    Inspect Case    Untrusted body content    1    1    0    PASS
    Inspect Case    No requests    0    0    0    PASS
    Inspect Case    Unknown request ID    0    0    0    FAIL
    Inspect Case    Skipped case    0    0    0    SKIP
