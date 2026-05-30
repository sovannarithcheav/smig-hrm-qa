@payment @payroll_frequency_configs @positive @e2e
Feature: PAY-FREQ-002 Payroll Frequency Config - Create and Approve

  Background:
    * url paymentUrl

  @e2e
  Scenario: Create BUSINESS_UNIT/2 config → CS approve → status becomes ACTIVE
    * print '=== STEP 1: Create config ==='
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'BUSINESS_UNIT', scopeId: 2, frequency: 'TWICE_MONTHLY', run1SalaryPct: 60.0, cutoffDay: 10 }
    When method POST
    Then status 200
    And match response.data.status == 'PENDING'
    * def configId = response.data.id
    * def requestChangeId = response.data.requestChangeId

    * print '=== STEP 2: Approve via CS ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    * karate.pause(1000)

    * print '=== STEP 3: Verify ACTIVE ==='
    * url paymentUrl
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId
    When method GET
    Then status 200
    And match response.data.config.status == 'ACTIVE'
    And match response.data.config.frequency == 'TWICE_MONTHLY'
    And match response.data.config.run1SalaryPct == 60.0
    And match response.data.config.cutoffDay == 10
