@payment @ot_configs @positive
Feature: PAY-001 List OT Configs

  Background:
    * url paymentUrl

  @smoke
  Scenario: Returns non-empty list with correct shape
    Given path '/api/v1/payment/payroll-ot-config'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    * assert response.data.length > 0
    And match each response.data == { id: '#number', otType: '#string', multiplier: '#number', updatedAt: '##string' }

  @smoke
  Scenario: All ids and otTypes are positive, unique, and multipliers are greater than zero
    Given path '/api/v1/payment/payroll-ot-config'
    When method GET
    Then status 200
    * def ids        = response.data.map(function(x){ return x.id })
    * def otTypes    = response.data.map(function(x){ return x.otType })
    * def multipliers = response.data.map(function(x){ return x.multiplier })
    * def isUnique   = function(arr){ return arr.length == arr.filter(function(v,i,a){ return a.indexOf(v) === i }).length }
    * assert ids.filter(function(id){ return id <= 0 }).length == 0
    * assert isUnique(ids)
    * assert isUnique(otTypes)
    * assert multipliers.filter(function(m){ return m <= 0 }).length == 0

  @smoke
  Scenario: Update multiplier - change is persisted and returned
    # Fetch current config to capture original multiplier
    Given path '/api/v1/payment/payroll-ot-config'
    When method GET
    Then status 200
    * def config           = response.data[0]
    * def originalMultiplier = config.multiplier
    * def newMultiplier      = originalMultiplier + 0.5

    Given path '/api/v1/payment/payroll-ot-config/' + config.id
    And request { multiplier: #(newMultiplier) }
    When method PUT
    Then status 200
    And match response.error == null
    And match response.data.id == config.id
    And match response.data.multiplier == newMultiplier

    # Restore original multiplier
    Given path '/api/v1/payment/payroll-ot-config/' + config.id
    And request { multiplier: #(originalMultiplier) }
    When method PUT
    Then status 200
    And match response.data.multiplier == originalMultiplier
