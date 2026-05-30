@payment @twice_monthly @positive @e2e
Feature: PAY-2M-001 Twice-Monthly Payroll Run - Run 1 and Run 2

  Background:
    * url paymentUrl

  @e2e
  Scenario: Create COMPANY TWICE_MONTHLY config → run Run 1 → run Run 2 → cancel both
    * print '=== STEP 1: Create COMPANY TWICE_MONTHLY config ==='
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 15 }
    When method POST
    Then status 200
    * def configId = response.data.id
    * def configRcId = response.data.requestChangeId

    * print '=== STEP 2: Approve frequency config ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + configRcId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    * karate.pause(1000)

    * print '=== STEP 3: Run 1 — period stored as 2099-11-1 ==='
    * url paymentUrl
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-11', scope: 'COMPANY', runNumber: 1 }
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.run.period == '2099-11-1'
    And match response.data.run.runNumber == 1
    And match response.data.run.scope == 'COMPANY'
    And match response.data.run.status == 'DRAFT'
    And match response.data.run.totalEmployees == '#number? _ > 0'
    And match response.data.batches == '#[]'
    * def run1Id = response.data.run.id

    * print '=== STEP 4: Cancel Run 1 ==='
    Given path '/api/v1/payment/payroll-runs/' + run1Id + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
    And match response.data.status == 'CANCELLED'

    * print '=== STEP 5: Run 2 — period stored as 2099-11-2 ==='
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-11', scope: 'COMPANY', runNumber: 2 }
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.run.period == '2099-11-2'
    And match response.data.run.runNumber == 2
    And match response.data.run.scope == 'COMPANY'
    And match response.data.run.status == 'DRAFT'
    And match response.data.run.totalEmployees == '#number? _ > 0'
    * def run2Id = response.data.run.id

    * print '=== STEP 6: Cancel Run 2 ==='
    Given path '/api/v1/payment/payroll-runs/' + run2Id + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
    And match response.data.status == 'CANCELLED'
