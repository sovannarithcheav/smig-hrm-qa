@payment @exchange_rate @positive
Feature: PAY-003 Exchange Rate - Get Latest

  Background:
    * url paymentUrl

  @smoke
  Scenario: Get latest USD→KHR - returns seeded rate
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'USD'
    And param toCurrency = 'KHR'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'KHR'
    And match response.data.rate == '#number'
    And match response.data.status == 'ACTIVE'
