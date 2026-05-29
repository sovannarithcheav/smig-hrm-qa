@payment @deductions @negative
Feature: PAY-DED-N-001 Create Deduction - validation failures

  Background:
    * url paymentUrl

  Scenario: amount zero returns 400
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request { "employeeId": 1, "deductionType": "DAMAGE", "amount": 0, "effectiveDate": "2026-06-01" }
    When method POST
    Then status 400
    And match response.error contains 'amount'

  Scenario: negative amount returns 400
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request { "employeeId": 1, "deductionType": "DAMAGE", "amount": -50, "effectiveDate": "2026-06-01" }
    When method POST
    Then status 400
    And match response.error contains 'amount'

  Scenario: unknown deductionType returns 400
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request { "employeeId": 1, "deductionType": "INVALID_TYPE", "amount": 50, "effectiveDate": "2026-06-01" }
    When method POST
    Then status 400
    And match response.error contains 'deduction type'

  Scenario: non-existent employeeId returns 400
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request { "employeeId": 999999, "deductionType": "DAMAGE", "amount": 50, "effectiveDate": "2026-06-01" }
    When method POST
    Then status 400
    And match response.error contains 'not found'

  Scenario: endDate before effectiveDate returns 400
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request { "employeeId": 1, "deductionType": "FINE", "amount": 50, "effectiveDate": "2026-06-30", "endDate": "2026-06-01" }
    When method POST
    Then status 400
    And match response.error contains 'endDate'
