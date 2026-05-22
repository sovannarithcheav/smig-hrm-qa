@payment
Feature: PAY-001 List OT Configs

  Background:
    * url paymentUrl

  @smoke
  Scenario: Returns OT config list wrapped in {data, error}
    Given path '/api/v1/payment/payroll-ot-config'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    And match each response.data contains { id: '#number', otType: '#string', multiplier: '#number' }
