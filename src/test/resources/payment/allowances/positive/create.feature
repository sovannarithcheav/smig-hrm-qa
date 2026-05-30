@payment @allowances @positive @create
Feature: PAY-ALL-001 Allowance - Create

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @smoke
  Scenario: Create employee-scoped allowance - returns 201 with PENDING status
    Given path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request { employeeId: #(empId), allowanceType: 'HOUSING', amount: 200.00, taxable: false, effectiveDate: '2026-06-01' }
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == empId
    And match response.data.allowanceType == 'HOUSING'
    And match response.data.amount == 200.0
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'

  @smoke
  Scenario: Create employment-type-scoped allowance - returns 201
    Given path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request { employmentType: 'FULL_TIME', allowanceType: 'TRANSPORT', amount: 50.00, taxable: true, effectiveDate: '2026-06-01', endDate: '2026-12-31' }
    When method POST
    Then status 201
    And match response.data.employmentType == 'FULL_TIME'
    And match response.data.endDate == '2026-12-31'
    And match response.data.status == 'PENDING'

  @smoke
  Scenario: List allowances - returns array
    Given path '/api/v1/payment/allowances'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Get by id - returns correct record
    * def created = call read('classpath:payment/allowances/helper/create-allowance.feature') { employeeId: #(empId), allowanceType: 'MEAL', amount: 30.0, taxable: false, effectiveDate: '2026-06-01' }
    Given path '/api/v1/payment/allowances/' + created.createdId
    When method GET
    Then status 200
    And match response.data.id == created.createdId
    And match response.data.allowanceType == 'MEAL'
