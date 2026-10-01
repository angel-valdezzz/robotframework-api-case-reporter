*** Settings ***
Library           RequestsLibrary
Library           RequestReporter
Library           support/LocalAPI.py
Library           DataDriver    file=${CURDIR}/data.csv    encoding=utf-8

Suite Setup       Prepare fixture
Suite Teardown    Verify generated reports
Test Template     Query from row


*** Test Cases ***
Distributor ${number}
    ${number}


*** Keywords ***
Prepare fixture
    ${url}=    Start API
    Set Suite Variable    ${BASE_URL}    ${url}

Query from row
    [Arguments]    ${number}
    Set Case Metadata    distributor=${number}
    ${response}=    GET    ${BASE_URL}/distribuidores/${number}    expected_status=anything
    ${id}=    Capture Response    Distributor query    ${response}
    Assert    ${id}    HTTP    Should Be Equal As Integers    ${response.status_code}    200

Verify generated reports
    Stop API
    Inspect Case    DDT distributor 1042    1    1    0    PASS
    Inspect Case    DDT distributor 1087    1    1    0    PASS
