@payment @deductions @positive @create
Feature: PAY-DED-002 Create Deduction

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @smoke
  Scenario: Create DAMAGE deduction - returns 201 with PENDING status
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request
      """
      {
        "employeeId": #(empId),
        "deductionType": "DAMAGE",
        "amount": 50.00,
        "effectiveDate": "2026-06-01",
        "remark": "Broken equipment"
      }
      """
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == empId
    And match response.data.deductionType == 'DAMAGE'
    And match response.data.amount == 50.0
    And match response.data.effectiveDate == '2026-06-01'
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    And match response.data.remark == 'Broken equipment'
    And match response.data.createdBy == '#number'
    And match response.data.createdAt == '#string'

  @smoke
  Scenario: Create ABSENCE deduction with endDate
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request
      """
      {
        "employeeId": #(empId),
        "deductionType": "ABSENCE",
        "amount": 25.00,
        "effectiveDate": "2026-06-01",
        "endDate": "2026-06-30",
        "remark": "Unexplained absence"
      }
      """
    When method POST
    Then status 201
    And match response.data.deductionType == 'ABSENCE'
    And match response.data.endDate == '2026-06-30'
    And match response.data.status == 'PENDING'

  @smoke
  Scenario: Create FINE deduction - lowercase type is normalized to uppercase
    Given path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request { "employeeId": #(empId), "deductionType": "fine", "amount": 10.0, "effectiveDate": "2026-06-01" }
    When method POST
    Then status 201
    And match response.data.deductionType == 'FINE'
    And match response.data.status == 'PENDING'
