@payment @exchange_rate @positive @create
Feature: PAY-003 Exchange Rate - Create

  Background:
    * url paymentUrl

  @smoke
  Scenario: Create exchange rate - returns 202 with pending response schema
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'EUR', rate: 1.08, effectiveDate: '2026-06-01' }
    When method POST
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'EUR'
    And match response.data.rate == 1.08
    And match response.data.effectiveDate == '2026-06-01'

  @smoke
  Scenario: Create exchange rate - currencies are normalized to uppercase
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'usd', toCurrency: 'eur', rate: 1.05, effectiveDate: '2026-07-01' }
    When method POST
    Then status 202
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'EUR'
