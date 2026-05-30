@payment @advance_pays @negative @create
Feature: PAY-ADV-N-001 Advance Pay - Create Negative

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  Scenario: Non-existent employeeId - returns 400
    Given path '/api/v1/payment/advance-pays'
    And header X-User-Id = userId
    And request { employeeId: 999999, amount: 500.0, repaymentMonths: 3, repaymentStartDate: '2026-07-01' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Invalid repaymentStartDate format - returns 400
    Given path '/api/v1/payment/advance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), amount: 500.0, repaymentMonths: 3, repaymentStartDate: 'not-a-date' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Cancel non-existent id - returns 400
    Given path '/api/v1/payment/advance-pays/999999/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.data == null
