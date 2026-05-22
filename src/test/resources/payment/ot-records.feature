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
        "hours": 3.0,
        "remark": "Karate test OT record"
      }
      """

  @smoke
  Scenario: Create OT record - returns 201 wrapped in {data, error}
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'

  @negative
  Scenario: Invalid clockIn format - returns 400
    Given path '/api/v1/payment/ot-records'
    And header X-User-Id = userId
    And request { "employeeId": 1, "otType": "NORMAL", "clockIn": "not-a-date" }
    When method POST
    Then status 400
    And match response.error contains 'clockIn'
    And match response.data == null

  @smoke
  Scenario: List OT records - returns list wrapped in {data, error}
    Given path '/api/v1/payment/ot-records'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @negative
  Scenario: Get non-existent OT record - returns 404
    Given path '/api/v1/payment/ot-records/999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null
