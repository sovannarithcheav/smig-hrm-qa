@payment @payroll_frequency_configs @positive @smoke
Feature: PAY-FREQ-003 Payroll Frequency Config - Get by ID

  Background:
    * url paymentUrl

  @smoke
  Scenario: Create SITE/1 config then GET by ID — returns config + components array
    Given path '/api/v1/payment/payroll-frequency-configs'
    And header X-User-Id = userId
    And request { scopeType: 'SITE', scopeId: 1, frequency: 'MONTHLY' }
    When method POST
    Then status 200
    * def configId = response.data.id

    Given path '/api/v1/payment/payroll-frequency-configs/' + configId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.config.id == configId
    And match response.data.config.scopeType == 'SITE'
    And match response.data.config.scopeId == 1
    And match response.data.config.frequency == 'MONTHLY'
    And match response.data.components == '#[]'

  @smoke
  Scenario: GET non-existent config — returns 404
    Given path '/api/v1/payment/payroll-frequency-configs/999999'
    When method GET
    Then status 404
