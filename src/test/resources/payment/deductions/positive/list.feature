@payment @deductions @positive
Feature: PAY-DED-001 List Deductions

  Background:
    * url paymentUrl

  @smoke
  Scenario: Happy path - returns array
    Given path '/api/v1/payment/deductions'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
