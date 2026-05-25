@notification
Feature: NT-005 Notification Variables - Negative

  Background:
    * url notificationUrl

  @negative
  Scenario: Get by id - non-numeric id returns 400
    Given path '/api/v1/notification/variables/abc'
    When method GET
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Get by id - non-existent id returns 404
    Given path '/api/v1/notification/variables/999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Get by eventCode - unknown eventCode returns 404
    Given path '/api/v1/notification/events/UNKNOWN_EVENT/variables'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null
