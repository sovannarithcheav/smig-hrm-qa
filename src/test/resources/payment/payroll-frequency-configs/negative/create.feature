@payment @payroll_frequency_configs @negative
Feature: PAY-FREQ-N-001 Payroll Frequency Config - Create Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Invalid scopeType — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'DEPARTMENT', frequency: 'MONTHLY' }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: BUSINESS_UNIT scope without scopeId — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'BUSINESS_UNIT', frequency: 'MONTHLY' }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: Invalid frequency — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'WEEKLY' }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: run1SalaryPct = 0 — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'TWICE_MONTHLY', run1SalaryPct: 0.0, cutoffDay: 15 }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: run1SalaryPct = 100 — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'TWICE_MONTHLY', run1SalaryPct: 100.0, cutoffDay: 15 }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: cutoffDay = 0 — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 0 }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: cutoffDay = 29 — returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 29 }
    When method POST
    Then status 400
    And match response.data == null

  @negative
  Scenario: Duplicate COMPANY scope — second POST returns 400
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'MONTHLY' }
    When method POST
    Then status 200
    # Duplicate
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'COMPANY', frequency: 'MONTHLY' }
    When method POST
    Then status 400
    And match response.data == null
