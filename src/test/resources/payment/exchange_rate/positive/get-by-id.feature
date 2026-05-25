@payment
Feature: PAY-003 Exchange Rate - Get by ID

  Background:
    * url paymentUrl

  @smoke
  Scenario: Get by id - returns correct record
    # Use seeded USD→KHR rate; list first to resolve the id
    Given path '/api/v1/payment/exchange-rates'
    And param fromCurrency = 'USD'
    And param toCurrency = 'KHR'
    When method GET
    Then status 200
    * assert response.data.length > 0
    * def seededId = response.data[0].id

    Given path '/api/v1/payment/exchange-rates/' + seededId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == seededId
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'KHR'
