@payment @payroll_frequency_configs @positive @smoke
Feature: PAY-FREQ-001 Payroll Frequency Config - Create

  Background:
    * url paymentUrl

  @smoke
  Scenario: Create BUSINESS_UNIT config — returns 200 with PENDING status and correct shape
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'BUSINESS_UNIT', scopeId: 1, frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 15 }
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.scopeType == 'BUSINESS_UNIT'
    And match response.data.scopeId == 1
    And match response.data.frequency == 'TWICE_MONTHLY'
    And match response.data.run1SalaryPct == 50.0
    And match response.data.cutoffDay == 15
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    And match response.data.createdBy == '#number'
    And match response.data.isActive == true
