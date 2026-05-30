@payment @allowances @negative @create
Feature: PAY-ALL-N-001 Allowance - Create Negative

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  Scenario: Neither employeeId nor employmentType provided - returns 400
    Given path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request { allowanceType: 'HOUSING', amount: 100.0, taxable: false, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Both employeeId and employmentType provided - returns 400
    Given path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request { employeeId: #(empId), employmentType: 'FULL_TIME', allowanceType: 'HOUSING', amount: 100.0, taxable: false, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Unknown allowanceType - returns 400
    Given path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request { employeeId: #(empId), allowanceType: 'UNKNOWN', amount: 100.0, taxable: false, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'allowance type'
    And match response.data == null

  Scenario: Invalid effectiveDate format - returns 400
    Given path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request { employeeId: #(empId), allowanceType: 'HOUSING', amount: 100.0, taxable: false, effectiveDate: '01/06/2026' }
    When method POST
    Then status 400
    And match response.data == null
