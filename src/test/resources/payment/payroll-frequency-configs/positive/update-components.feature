@payment @payroll_frequency_configs @positive @e2e
Feature: PAY-FREQ-005 Payroll Frequency Config - Update Components

  Background:
    * url paymentUrl

  @e2e
  Scenario: Create SITE/2 config → approve → update components → approve → components stored
    * print '=== STEP 1: Create SITE/2 TWICE_MONTHLY config ==='
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'SITE', scopeId: 2, frequency: 'TWICE_MONTHLY', run1SalaryPct: 50.0, cutoffDay: 15 }
    When method POST
    Then status 200
    * def configId = response.data.id
    * def createRcId = response.data.requestChangeId

    * print '=== STEP 2: Approve config creation ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + createRcId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    * karate.pause(1000)

    * print '=== STEP 3: PUT components ==='
    * url paymentUrl
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId + '/components'
    And header X-User-Id = userId
    And request
      """
      {
        "components": [
          { "componentType": "ALLOWANCE",   "assignment": "SPLIT", "run1Pct": 50.0 },
          { "componentType": "BONUS",       "assignment": "RUN_2" },
          { "componentType": "DEDUCTION",   "assignment": "RUN_2" },
          { "componentType": "ADVANCE_PAY", "assignment": "RUN_2" },
          { "componentType": "LOAN",        "assignment": "RUN_2" },
          { "componentType": "NSSF",        "assignment": "RUN_2" },
          { "componentType": "INCOME_TAX",  "assignment": "RUN_2" }
        ]
      }
      """
    When method PUT
    Then status 200
    And match response.error == null
    And match response.data.config.status == 'UPDATING'
    * def compRcId = response.data.config.requestChangeId

    * print '=== STEP 4: Approve component update ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + compRcId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    * karate.pause(1000)

    * print '=== STEP 5: Verify ACTIVE with components ==='
    * url paymentUrl
    Given path '/api/v1/payment/payroll-frequency-configs/' + configId
    When method GET
    Then status 200
    And match response.data.config.status == 'ACTIVE'
    And match response.data.components == '#[_ >= 7]'
    * def allowanceComp = karate.jsonPath(response.data.components, "$[?(@.componentType=='ALLOWANCE')]")[0]
    And match allowanceComp.assignment == 'SPLIT'
    And match allowanceComp.run1Pct == 50.0
