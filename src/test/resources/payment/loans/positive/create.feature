@payment @loans @positive @create
Feature: PAY-LOAN-001 Loan - Create

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @smoke
  Scenario: Create loan - returns 201 with PENDING status
    Given path '/api/v1/payment/loans'
    And header X-User-Id = userId
    And request { employeeId: #(empId), loanType: 'PERSONAL', principalAmount: 2000.00, interestRate: 0.05, repaymentMonths: 12, disbursementDate: '2026-06-01', repaymentStartDate: '2026-07-01', remark: 'Personal loan' }
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == empId
    And match response.data.loanType == 'PERSONAL'
    And match response.data.principalAmount == 2000.0
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    And match response.data.monthlyInstallment == '#number'
    * def createdId = response.data.id
    # Cleanup
    Given path '/api/v1/payment/loans/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202

  @smoke
  Scenario: List loans - returns array
    Given path '/api/v1/payment/loans'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Get by id - returns correct record
    * def created = call read('classpath:payment/loans/helper/create-loan.feature') { employeeId: #(empId), loanType: 'EMERGENCY', principalAmount: 1000.0, interestRate: 0.0, repaymentMonths: 6, disbursementDate: '2026-06-01', repaymentStartDate: '2026-07-01' }
    Given path '/api/v1/payment/loans/' + created.createdId
    When method GET
    Then status 200
    And match response.data.id == created.createdId
    And match response.data.loanType == 'EMERGENCY'
    # Cleanup
    Given path '/api/v1/payment/loans/' + created.createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202
