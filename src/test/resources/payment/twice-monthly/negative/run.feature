@payment @twice_monthly @negative
Feature: PAY-2M-N-001 Twice-Monthly Payroll Run - Negative Validation

  Background:
    * url paymentUrl

  @negative
  Scenario: MONTHLY default (no config) — runNumber=1 → 400 "null for MONTHLY"
    # BeforeAll cleaned all frequency configs, so COMPANY defaults to MONTHLY
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-11', scope: 'COMPANY', runNumber: 1 }
    When method POST
    Then status 400
    And match response.error contains 'null for MONTHLY'
    And match response.data == null

  @negative
  Scenario: TWICE_MONTHLY config for SITE/1 — LOCATION run with no runNumber → 400 "runNumber"
    # Create + approve a SITE/1 TWICE_MONTHLY config (does not conflict with COMPANY scope)
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'SITE', scopeId: 1, frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 15 }
    When method POST
    Then status 200
    * def siteConfigRcId = response.data.requestChangeId

    * url changeManagementUrl
    Given path '/api/v1/request-change/' + siteConfigRcId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    * karate.pause(1000)

    # LOCATION run for siteId=1 without runNumber — TWICE_MONTHLY config resolved → runNumber required
    * url paymentUrl
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-11', scope: 'LOCATION', siteId: 1 }
    When method POST
    Then status 400
    And match response.error contains 'runNumber'
    And match response.data == null
