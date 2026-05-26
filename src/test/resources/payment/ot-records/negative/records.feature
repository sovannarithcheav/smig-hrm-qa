@payment @ot_records @negative
Feature: PAY-002 OT Records - Negative

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

  @negative
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
