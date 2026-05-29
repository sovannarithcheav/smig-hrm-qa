@payment @nssf_reports @positive
Feature: PAY-NSSF-003 NSSF Report Export (CSV)

  Background:
    * url paymentUrl
    * def setup = callonce read('classpath:payment/payroll-runs/helper/create-run.feature') { period: '2099-09' }
    * def runId = setup.runId

  @smoke
  Scenario: Export returns 200 with text/csv content type and attachment header
    Given path '/api/v1/payment/nssf-reports/' + runId + '/export'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/csv'
    And match responseHeaders['Content-Disposition'][0] contains 'attachment'
    And match responseHeaders['Content-Disposition'][0] contains 'nssf-report-2099-09.csv'

  @smoke
  Scenario: CSV body contains header row and TOTAL row
    Given path '/api/v1/payment/nssf-reports/' + runId + '/export'
    When method GET
    Then status 200
    And match response contains 'Employee ID'
    And match response contains 'NSSF Base'
    And match response contains 'TOTAL'

  Scenario: Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
