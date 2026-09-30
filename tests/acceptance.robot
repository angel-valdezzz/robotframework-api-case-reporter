*** Settings ***
Library          RequestsLibrary
Library          String
Library          APICaseReporter    WITH NAME    Report
Library          support/LocalAPI.py
Suite Setup      Start Fixture
Suite Teardown   Verify Reports

*** Test Cases ***
Passing distributor
    ${token}=    Get token
    ${body}    ${id}=    Get distributor    1042    ${token}
    Verify distributor data    ${id}    ${body}

Failing distributor
    [Tags]    expected-failure
    ${token}=    Get token
    ${body}    ${id}=    Get distributor    1087    ${token}
    Verify distributor data    ${id}    ${body}

Non JSON error response
    ${response}=    GET    ${BASE_URL}/broken    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Upstream error    ${response}
    Report.Check    ${id}    Expected HTTP error    Should Be Equal As Integers    ${response.status_code}    502

Invalid JSON stops parsing
    [Tags]    expected-failure
    ${response}=    GET    ${BASE_URL}/non-json    expected_status=anything
    Report.Capture HTTP Exchange    Invalid JSON    ${response}
    ${body}=    Set Variable    ${response.json()}
    Fail    Should not reach this step

Binary response
    ${response}=    GET    ${BASE_URL}/binary    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Binary    ${response}
    Report.Check    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200

Empty fields
    [Tags]    expected-failure
    ${response}=    GET    ${BASE_URL}/distribuidores/1042    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Empty values    ${response}
    Verify empty values    ${id}

Untrusted body content
    ${response}=    GET    ${BASE_URL}/hostile    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Untrusted text    ${response}
    Report.Check    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200

No requests
    Report.Set Case Metadata    case_id=EMPTY
    No Operation

Unknown request ID
    [Tags]    expected-failure
    Report.Check    unknown    Invalid ID    Should Be Equal    a    a

Skipped case
    Skip    Demonstrate a skipped report

Timeout without response
    [Tags]    expected-failure
    GET    ${BASE_URL}/slow    timeout=0.01    expected_status=anything

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

Duplicate name
    No Operation

Duplicate name
    No Operation

*** Keywords ***
Start Fixture
    ${url}=    Start API
    Set Suite Variable    ${BASE_URL}    ${url}

Get token
    ${form}=    Create Dictionary    client_secret=fixture-secret-SECRET
    ${response}=    POST    ${BASE_URL}/oauth/token    data=${form}    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Obtener token    ${response}
    Report.Check    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    Report.Check    ${id}    Token presente    Should Not Be Empty    ${body}[access_token]
    RETURN    ${body}[access_token]

Get distributor
    [Arguments]    ${number}    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET    url=${BASE_URL}/distribuidores/${number}?api_key=query-secret-SECRET
    ...    headers=${headers}    expected_status=anything
    ${id}=    Report.Capture HTTP Exchange    Consultar distribuidor    ${response}
    Report.Check    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    RETURN    ${body}    ${id}

Verify distributor data
    [Tags]    robot:continue-on-failure
    [Arguments]    ${id}    ${body}
    Report.Check    ${id}    Verificar tipo distribuidor
    ...    Should Be Equal As Strings    ${body}[tipoDistribuidor]    AGENTE
    Report.Check    ${id}    Verificar tipo persona
    ...    Should Be Equal As Strings    ${body}[tipoPersona]    FISICA
    Report.Check    ${id}    Verificar RFC no vacío    Campo Debe Tener Contenido    ${body.get('rfc')}
    Report.Check    ${id}    Verificar CURP no vacía    Campo Debe Tener Contenido    ${body.get('curp')}

Campo Debe Tener Contenido
    [Arguments]    ${value}
    Should Not Be Equal    ${value}    ${NONE}
    ${text}=    Convert To String    ${value}
    ${text}=    Strip String    ${text}
    Should Not Be Empty    ${text}

Verify empty values
    [Tags]    robot:continue-on-failure
    [Arguments]    ${id}
    Report.Check    ${id}    Null    Campo Debe Tener Contenido    ${NONE}
    Report.Check    ${id}    Empty    Campo Debe Tener Contenido    ${EMPTY}
    Report.Check    ${id}    Whitespace    Campo Debe Tener Contenido    ${SPACE}${SPACE}

Verify Reports
    Stop API
    Inspect Case    Passing distributor    2    7    0    PASS
    Inspect Case    Failing distributor    2    5    2    FAIL
    Inspect Case    Non JSON error response    1    1    0    PASS
    Inspect Case    Invalid JSON stops parsing    1    0    0    FAIL
    Inspect Case    Binary response    1    1    0    PASS
    Inspect Case    Empty fields    1    0    3    FAIL
    Inspect Case    Untrusted body content    1    1    0    PASS
    Inspect Case    No requests    0    0    0    PASS
    Inspect Case    Unknown request ID    0    0    0    FAIL
    Inspect Case    Skipped case    0    0    0    SKIP
