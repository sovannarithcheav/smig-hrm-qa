@payment
Feature: PAY-002 OT Records

  Background:
    * url paymentUrl
    * def uniqueEmployeeId = Math.floor(Math.random() * 900000) + 100000
    * def validBody =
      """
      {
        "employeeId": #(uniqueEmployeeId),
        "otType": "WEEKDAY",
        "clockIn": "2026-05-22T08:00:00",
        "clockOut": "2026-05-22T11:00:00",
        "remark": "Karate test OT record"
      }
      """

  # ---------- Create ----------

  @smoke
  Scenario: Create OT record - returns 201 with full field schema
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == uniqueEmployeeId
    And match response.data.otType == 'WEEKDAY'
    And match response.data.clockIn == '#string'
    And match response.data.clockOut == '#string'
    And match response.data.hours == '#number'
    And match response.data.multiplier == '#number'
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    And match response.data.createdBy == '#number'

  @smoke
  Scenario: Create with explicit hours - hours value is persisted as provided
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { employeeId: #(uniqueEmployeeId), otType: 'WEEKDAY', clockIn: '2026-05-22T08:00:00', hours: 5.0 }
    When method POST
    Then status 201
    And match response.data.hours == 5.0
    And match response.data.status == 'PENDING'

  @smoke
  Scenario: Create - duplicate pending employee returns 400
    # First record
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 201
    * def createdEmployeeId = response.data.employeeId

    # Second record same employee
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { employeeId: #(createdEmployeeId), otType: 'WEEKDAY', clockIn: '2026-05-22T08:00:00', clockOut: '2026-05-22T10:00:00' }
    When method POST
    Then status 400
    And match response.error contains 'active OT record'
    And match response.data == null

  # ---------- List ----------

  @smoke
  Scenario: List OT records - returns list with correct item shape
    Given path '/api/v1/payment/ot-records'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    * def itemSchema = { id: '#number', employeeId: '#number', otType: '#string', clockIn: '#string', clockOut: '##string', hours: '#number', multiplier: '#number', status: '#string', requestChangeId: '##number', remark: '##string', createdBy: '#number', createdAt: '#string', updatedAt: '##string' }
    * match each response.data == itemSchema

  @smoke
  Scenario: List - filter by employeeId returns only that employee's records
    # Create a record so we know at least one exists for this employeeId
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 201
    * def empId = response.data.employeeId

    Given path '/api/v1/payment/ot-records'
    And param employeeId = empId
    When method GET
    Then status 200
    * assert response.data.length > 0
    * karate.forEach(response.data, function(r){ karate.match(r.employeeId, empId) })

  @smoke
  Scenario: List - filter by status returns only matching records
    Given path '/api/v1/payment/ot-records'
    And param status = 'PENDING'
    When method GET
    Then status 200
    And match response.data == '#array'
    * karate.forEach(response.data, function(r){ karate.match(r.status, 'PENDING') })

  # ---------- Get by id ----------

  @smoke
  Scenario: Get by id - returns correct record matching created data
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 201
    * def createdId = response.data.id

    Given path '/api/v1/payment/ot-records/' + createdId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == createdId
    And match response.data.employeeId == uniqueEmployeeId
    And match response.data.status == 'PENDING'

  @negative
  Scenario: Get by id - non-numeric id returns 400
    Given path '/api/v1/payment/ot-records/abc'
    When method GET
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Get by id - non-existent id returns 404
    Given path '/api/v1/payment/ot-records/999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  # ---------- Negative - Create ----------

  @negative
  Scenario: Invalid clockIn format - returns 400
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { "employeeId": 1, "otType": "WEEKDAY", "clockIn": "not-a-date", "clockOut": "2026-05-22T11:00:00" }
    When method POST
    Then status 400
    And match response.error contains 'clockIn'
    And match response.data == null

  @negative
  Scenario: Invalid clockOut format - returns 400
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { "employeeId": 1, "otType": "WEEKDAY", "clockIn": "2026-05-22T08:00:00", "clockOut": "not-a-date" }
    When method POST
    Then status 400
    And match response.error contains 'clockOut'
    And match response.data == null

  @negative
  Scenario: Unknown otType - returns 400
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { "employeeId": #(uniqueEmployeeId), "otType": "INVALID_TYPE", "clockIn": "2026-05-22T08:00:00", "clockOut": "2026-05-22T11:00:00" }
    When method POST
    Then status 400
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Missing clockOut and hours - returns 400
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { "employeeId": #(uniqueEmployeeId), "otType": "WEEKDAY", "clockIn": "2026-05-22T08:00:00" }
    When method POST
    Then status 400
    And match response.error != null
    And match response.data == null
