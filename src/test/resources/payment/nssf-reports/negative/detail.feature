@payment @nssf_reports @negative
Feature: PAY-NSSF-N-001 NSSF Report - not found

  Background:
    * url paymentUrl

  Scenario: Unknown payrollRunId on detail returns 404
    Given path '/api/v1/payment/nssf-reports/999999'
    When method GET
    Then status 404

  Scenario: Unknown payrollRunId on export returns 404
    Given path '/api/v1/payment/nssf-reports/999999/export'
    When method GET
    Then status 404
