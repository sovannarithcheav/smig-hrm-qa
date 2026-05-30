@payment @loans @negative @create
Feature: PAY-LOAN-N-001 Loan - Create Negative

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  Scenario: Non-existent employeeId - returns 400
    Given path '/api/v1/payment/loans'
    And header X-User-Id = userId
    And request { employeeId: 999999, loanType: 'PERSONAL', principalAmount: 1000.0, interestRate: 0.05, repaymentMonths: 6, disbursementDate: '2026-06-01', repaymentStartDate: '2026-07-01' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Unknown loanType - returns 400
    Given path '/api/v1/payment/loans'
    And header X-User-Id = userId
    And request { employeeId: #(empId), loanType: 'UNKNOWN_TYPE', principalAmount: 1000.0, interestRate: 0.05, repaymentMonths: 6, disbursementDate: '2026-06-01', repaymentStartDate: '2026-07-01' }
    When method POST
    Then status 400
    And match response.error contains 'loan type'
    And match response.data == null

  Scenario: Invalid disbursementDate format - returns 400
    Given path '/api/v1/payment/loans'
    And header X-User-Id = userId
    And request { employeeId: #(empId), loanType: 'PERSONAL', principalAmount: 1000.0, interestRate: 0.05, repaymentMonths: 6, disbursementDate: 'bad-date', repaymentStartDate: '2026-07-01' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Cancel non-existent id - returns 400
    Given path '/api/v1/payment/loans/999999/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.data == null
