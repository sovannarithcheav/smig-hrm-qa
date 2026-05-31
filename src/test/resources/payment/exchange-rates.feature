@payment
Feature: PAY-003 Exchange Rates

  Background:
    * url paymentUrl

  # ---------- Create ----------

  @smoke
  Scenario: Create exchange rate - returns 202 with pending response schema
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'EUR', rate: 1.08, effectiveDate: '2026-06-01' }
    When method POST
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'EUR'
    And match response.data.rate == 1.08
    And match response.data.effectiveDate == '2026-06-01'

  @smoke
  Scenario: Create exchange rate - currencies are normalized to uppercase
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'usd', toCurrency: 'eur', rate: 1.05, effectiveDate: '2026-07-01' }
    When method POST
    Then status 202
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'EUR'

  # ---------- List ----------

  @smoke
  Scenario: List exchange rates - returns array with correct item shape
    Given path '/api/v1/payment/exchange-rates'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    * def itemSchema = { id: '#number', fromCurrency: '#string', toCurrency: '#string', rate: '#number', effectiveDate: '#string', status: '#string', requestChangeId: '##number', createdBy: '#number', createdAt: '#string', updatedAt: '##string' }
    * match each response.data == itemSchema

  @smoke
  Scenario: List - filter by fromCurrency returns only matching records
    Given path '/api/v1/payment/exchange-rates'
    And param fromCurrency = 'USD'
    When method GET
    Then status 200
    * karate.forEach(response.data, function(r){ karate.match(r.fromCurrency, 'USD') })

  @smoke
  Scenario: List - filter by fromCurrency and toCurrency
    Given path '/api/v1/payment/exchange-rates'
    And param fromCurrency = 'USD'
    And param toCurrency = 'KHR'
    When method GET
    Then status 200
    * karate.forEach(response.data, function(r){ karate.match(r.fromCurrency, 'USD') })
    * karate.forEach(response.data, function(r){ karate.match(r.toCurrency, 'KHR') })

  # ---------- Get by id ----------

  @smoke
  Scenario: Get by id - returns correct record
    # Use seeded USD→KHR rate; list first to resolve the id
    Given path '/api/v1/payment/exchange-rates'
    And param fromCurrency = 'USD'
    And param toCurrency = 'KHR'
    When method GET
    Then status 200
    * assert response.data.length > 0
    * def seededId = response.data[0].id

    Given path '/api/v1/payment/exchange-rates/' + seededId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == seededId
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'KHR'

  @negative
  Scenario: Get by id - non-numeric id returns 400
    Given path '/api/v1/payment/exchange-rates/abc'
    When method GET
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Get by id - non-existent id returns 404
    Given path '/api/v1/payment/exchange-rates/999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  # ---------- Get latest ----------

  @smoke
  Scenario: Get latest USD→KHR - returns seeded rate
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'USD'
    And param toCurrency = 'KHR'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'KHR'
    And match response.data.rate == '#number'
    And match response.data.status == 'ACTIVE'

  @negative
  Scenario: Get latest - missing fromCurrency returns 400
    Given path '/api/v1/payment/exchange-rates/latest'
    And param toCurrency = 'KHR'
    When method GET
    Then status 400
    And match response.error contains 'fromCurrency'
    And match response.data == null

  @negative
  Scenario: Get latest - missing toCurrency returns 400
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'USD'
    When method GET
    Then status 400
    And match response.error contains 'toCurrency'
    And match response.data == null

  @negative
  Scenario: Get latest - no rate found for pair returns 404
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'JPY'
    And param toCurrency = 'GBP'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  # ---------- E2E: Create + CS Approval ----------

  @smoke @e2e
  Scenario: Create exchange rate then approve via CS - record becomes ACTIVE
    # Date 20 years from now — far enough that repeated runs never conflict with each other
    * def testDate = function(){ var d = new Date(); d.setFullYear(d.getFullYear() + 20); return d.toISOString().split('T')[0] }
    * def effectiveDate = testDate()

    # Create — no DB record yet, only a CS request is queued
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'SGD', rate: 1.35, effectiveDate: '#(effectiveDate)' }
    When method POST
    Then status 202
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    # Approve via Change Management Service
    # participantId for exchange_rate requests equals the requester's userId (set by ExchangeRateService)
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    # Allow CS callback to reach payment service
    * karate.pause(1000)

    # Verify the record is now ACTIVE in payment service
    * url paymentUrl
    Given path '/api/v1/payment/exchange-rates/latest'
    And param fromCurrency = 'USD'
    And param toCurrency = 'SGD'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.fromCurrency == 'USD'
    And match response.data.toCurrency == 'SGD'
    And match response.data.rate == 1.35
    And match response.data.status == 'ACTIVE'

  # ---------- Negative - Create ----------

  @negative
  Scenario: Create - rate zero returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: 0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'positive'
    And match response.data == null

  @negative
  Scenario: Create - rate negative returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: -1.0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'positive'
    And match response.data == null

  @negative
  Scenario: Create - fromCurrency same as toCurrency returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'USD', rate: 1.0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains 'differ'
    And match response.data == null

  @negative
  Scenario: Create - fromCurrency not 3 letters returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'US', toCurrency: 'KHR', rate: 4100.0, effectiveDate: '2026-06-01' }
    When method POST
    Then status 400
    And match response.error contains '3-letter'
    And match response.data == null

  @negative
  Scenario: Create - invalid effectiveDate format returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: 4100.0, effectiveDate: '01-06-2026' }
    When method POST
    Then status 400
    And match response.error contains 'effectiveDate'
    And match response.data == null

  @negative
  Scenario: Create - duplicate effectiveDate for active pair returns 400
    Given path '/api/v1/payment/exchange-rates'
    And header X-User-Id = userId
    And request { fromCurrency: 'USD', toCurrency: 'KHR', rate: 4200.0, effectiveDate: '2025-01-01' }
    When method POST
    Then status 400
    And match response.error contains 'already exists'
    And match response.data == null
