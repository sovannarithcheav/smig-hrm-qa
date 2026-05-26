@payment @exchange_rate @positive
Feature: PAY-003 Exchange Rate - List

  Background:
    * url paymentUrl

  @smoke
  Scenario: List exchange rates - returns array with correct item shape
    Given path '/api/v1/payment/exchange-rates'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    * def itemSchema = { id: '#number', fromCurrency: '#string', toCurrency: '#string', rate: '#number', effectiveDate: '#string', status: '#string', createdBy: '#number', createdAt: '#string' }
    * match each response.data == itemSchema

  @smoke
  Scenario: List - filter by fromCurrency returns only matching records
    Given path '/api/v1/payment/exchange-rates'
    And param fromCurrency = 'USD'
    When method GET
    Then status 200
    * karate.forEach(response.data, function(r){ karate.match(r.fromCurrency, 'USD') })

  @smoke
  Scenario: List - filter by fromCurrency and toCurrency
    Given path '/api/v1/payment/exchange-rates'
    And param fromCurrency = 'USD'
    And param toCurrency = 'KHR'
    When method GET
    Then status 200
    * karate.forEach(response.data, function(r){ karate.match(r.fromCurrency, 'USD') })
    * karate.forEach(response.data, function(r){ karate.match(r.toCurrency, 'KHR') })
