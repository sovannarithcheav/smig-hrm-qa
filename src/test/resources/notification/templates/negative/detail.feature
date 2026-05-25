@notification
Feature: NT-002 Notification Template Detail - Negative

  Background:
    * url notificationUrl

  @negative
  Scenario: Non-numeric id - returns 400
    Given path '/api/v1/notification/templates/abc'
    When method GET
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Non-existent id - returns 404
    Given path '/api/v1/notification/templates/999999'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Boundary id zero - returns 404 not 500
    Given path '/api/v1/notification/templates/0'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Negative id - returns 404 not 500
    Given path '/api/v1/notification/templates/-1'
    When method GET
    Then status 404
    And match response.error != null
    And match response.data == null
