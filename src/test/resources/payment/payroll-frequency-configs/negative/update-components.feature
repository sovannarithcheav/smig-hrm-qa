@payment @payroll_frequency_configs @negative
Feature: PAY-FREQ-N-002 Payroll Frequency Config - Update Components Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Component assignment validation — create COMPANY config, then test all invalid inputs
    # Setup: create + approve COMPANY TWICE_MONTHLY config
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'BUSINESS_UNIT', scopeId: 3, frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 15 }
    When method POST
    Then status 200
    * def configId = response.data.id
    * def createRcId = response.data.requestChangeId

    * url changeManagementUrl
    Given path '/api/v1/request-change/' + createRcId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    * karate.pause(1000)

    # BASIC_SALARY locked to SPLIT — RUN_1 must be rejected
    * url paymentUrl
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId + '/components'
    And header X-User-Id = userId
    And request { components: [{ componentType: 'BASIC_SALARY', assignment: 'RUN_1' }] }
    When method PUT
    Then status 400
    And match response.data == null

    # INCOME_TAX blocked from SPLIT
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId + '/components'
    And header X-User-Id = userId
    And request { components: [{ componentType: 'INCOME_TAX', assignment: 'SPLIT', run1Pct: 50.0 }] }
    When method PUT
    Then status 400
    And match response.data == null

    # Invalid assignment value
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId + '/components'
    And header X-User-Id = userId
    And request { components: [{ componentType: 'BONUS', assignment: 'HALF' }] }
    When method PUT
    Then status 400
    And match response.data == null

    # SPLIT without run1Pct
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId + '/components'
    And header X-User-Id = userId
    And request { components: [{ componentType: 'ALLOWANCE', assignment: 'SPLIT' }] }
    When method PUT
    Then status 400
    And match response.data == null

    # RUN_1 with non-null run1Pct — run1Pct must be null when not SPLIT
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId + '/components'
    And header X-User-Id = userId
    And request { components: [{ componentType: 'BONUS', assignment: 'RUN_1', run1Pct: 50.0 }] }
    When method PUT
    Then status 400
    And match response.data == null
