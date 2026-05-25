@payment @create
Feature: PAY-003 Exchange Rate - Create Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Create - rate zero returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: 0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'positive'
    And match response.data == null

  @negative
  Scenario: Create - rate negative returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: -1.0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'positive'
    And match response.data == null

  @negative
  Scenario: Create - fromCurrency same as toCurrency returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'USD', rate: 1.0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'differ'
    And match response.data == null

  @negative
  Scenario: Create - fromCurrency not 3 letters returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'US', toCurrency: 'KHR', rate: 4100.0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains '3-letter'
    And match response.data == null

  @negative
  Scenario: Create - invalid effectiveDate format returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: 4100.0, effectiveDate: '01-06-2026' }
    When method POST
    Then status 400
    And match response.error contains 'effectiveDate'
    And match response.data == null

  @negative
  Scenario: Create - duplicate effectiveDate for active pair returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: 4200.0, effectiveDate: '2025-01-01' }
    When method POST
    Then status 400
    And match response.error contains 'already exists'
    And match response.data == null
