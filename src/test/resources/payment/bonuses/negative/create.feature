@payment @bonuses @negative @create
Feature: PAY-BONUS-N-001 Bonus - Create Negative

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  Scenario: Unknown bonusType - returns 400
    Given path '/api/v1/payment/bonuses'
    And header X-User-Id = userId
    And request { employeeId: #(empId), bonusType: 'INVALID_TYPE', amount: 500.0, taxable: false, paymentPeriod: '2026-06' }
    When method POST
    Then status 400
    And match response.error contains 'bonus type'
    And match response.data == null

  Scenario: Invalid paymentPeriod format - returns 400
    Given path '/api/v1/payment/bonuses'
    And header X-User-Id = userId
    And request { employeeId: #(empId), bonusType: 'PERFORMANCE', amount: 500.0, taxable: false, paymentPeriod: '06-2026' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Non-existent employeeId - returns 400
    Given path '/api/v1/payment/bonuses'
    And header X-User-Id = userId
    And request { employeeId: 999999, bonusType: 'PERFORMANCE', amount: 500.0, taxable: false, paymentPeriod: '2026-06' }
    When method POST
    Then status 400
    And match response.data == null
