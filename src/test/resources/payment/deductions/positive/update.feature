@payment @deductions @positive
Feature: PAY-DED-003 Update Deduction

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1
    * def created = call read('classpath:payment/deductions/helper/create-deduction.feature') { "employeeId": #(empId), "deductionType": "FINE", "amount": 100.0, "effectiveDate": "2026-06-01", "remark": "For update test" }
    * def deductionId = created.createdId

  @smoke
  Scenario: Update on PENDING deduction returns 400 - must be ACTIVE first
    Given path '/api/v1/payment/deductions/' + deductionId
    And header X-User-Id = userId
    And request { "amount": 200.0 }
    When method PUT
    Then status 400
    And match response.error contains 'ACTIVE'

  @smoke
  Scenario: Deactivate on PENDING deduction returns 400 - must be ACTIVE first
    Given path '/api/v1/payment/deductions/' + deductionId + '/deactivate'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error contains 'ACTIVE'
