@payment
Feature: PAY-003 Exchange Rate - Get Latest Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Get latest - missing fromCurrency returns 400
    Given path '/api/v1/payment/exchange-rates/latest'
    And param toCurrency = 'KHR'
    When method GET
    Then status 400
    And match response.error contains 'fromCurrency'
    And match response.data == null

  @negative
  Scenario: Get latest - missing toCurrency returns 400
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'USD'
    When method GET
    Then status 400
    And match response.error contains 'toCurrency'
    And match response.data == null

  @negative
  Scenario: Get latest - no rate found for pair returns 404
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'JPY'
    And param toCurrency = 'GBP'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null
