@payment
Feature: PAY-003 Exchange Rate - Get by ID Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Get by id - non-numeric id returns 400
    Given path '/api/v1/payment/exchange-rates/abc'
    When method GET
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Get by id - non-existent id returns 404
    Given path '/api/v1/payment/exchange-rates/999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null
