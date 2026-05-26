@payment @exchange_rate @positive @e2e
Feature: PAY-003 Exchange Rate - E2E Create + CS Approval

  Background:
    * url paymentUrl

  Scenario: Create exchange rate then approve via CS - record becomes ACTIVE
    # Generate unique 3-letter test codes per run so same-day re-runs never collide
    * def genCode = function(n){ var a = n%26; var b = Math.floor(n/26)%26; return 'T'+String.fromCharCode(65+b)+String.fromCharCode(65+a) }
    * def seed = new Date().getTime() % 676
    * def fromCurrency = genCode(seed)
    * def toCurrency = genCode((seed + 1) % 676 == seed ? (seed + 2) % 676 : (seed + 1) % 676)
    * def effectiveDate = new Date().toISOString().split('T')[0]

    * print '=== STEP 1: Request create via payment service ==='
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: '#(fromCurrency)', toCurrency: '#(toCurrency)', rate: 1.35, effectiveDate: '#(effectiveDate)' }
    When method POST
    Then status 202
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    * print '=== STEP 2: Approve via Change Management Service ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    * karate.pause(1000)

    * print '=== STEP 3: Verify record is ACTIVE via /latest ==='
    * url paymentUrl
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = fromCurrency
    And param toCurrency = toCurrency
    When method GET
    Then status 200
    And match response.data.fromCurrency == fromCurrency
    And match response.data.toCurrency == toCurrency
    And match response.data.rate == 1.35
    And match response.data.effectiveDate == effectiveDate
    And match response.data.status == 'ACTIVE'
