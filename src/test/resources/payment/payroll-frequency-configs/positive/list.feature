@payment @payroll_frequency_configs @positive @smoke
Feature: PAY-FREQ-004 Payroll Frequency Config - List

  Background:
    * url paymentUrl

  @smoke
  Scenario: GET list — returns array (configs created by prior tests in this runner)
    Given path '/api/v1/payment/payroll-frequency-configs'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[]'
