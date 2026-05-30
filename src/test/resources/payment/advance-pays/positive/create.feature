@payment @advance_pays @positive @create
Feature: PAY-ADV-001 Advance Pay - Create

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @smoke
  Scenario: Create advance pay - returns 201 with PENDING status
    Given path '/api/v1/payment/advance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), amount: 500.00, repaymentMonths: 3, repaymentStartDate: '2026-07-01', remark: 'Emergency advance' }
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == empId
    And match response.data.amount == 500.0
    And match response.data.repaymentMonths == 3
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    And match response.data.monthlyDeduction == '#number'

  @smoke
  Scenario: List advance pays - returns array
    Given path '/api/v1/payment/advance-pays'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Get by id - returns correct record
    * def created = call read('classpath:payment/advance-pays/helper/create-advance-pay.feature') { employeeId: #(empId), amount: 300.0, repaymentMonths: 2, repaymentStartDate: '2026-07-01' }
    Given path '/api/v1/payment/advance-pays/' + created.createdId
    When method GET
    Then status 200
    And match response.data.id == created.createdId
    And match response.data.status == 'PENDING'
