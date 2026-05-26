@payment @severance_pays @negative
Feature: PAY-004 Severance Pay - Get by ID Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Get non-existent id - returns 404
    Given path '/api/v1/payment/severance-pays/999999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Get with non-numeric id - returns 400
    Given path '/api/v1/payment/severance-pays/abc'
    When method GET
    Then status 400
    And match response.error != null
    And match response.data == null
