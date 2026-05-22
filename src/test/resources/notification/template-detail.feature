@notification
Feature: NT-002 Notification Template Detail

  Background:
    * url notificationUrl

  @smoke
  Scenario: Valid id - returns enriched template with event, channel, status as objects
    Given path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.event == '#notnull'
    And match response.data.event.id == '#number'
    And match response.data.event.code == '#string'
    And match response.data.channel == '#notnull'
    And match response.data.status == '#notnull'
    And match response.data.status.id == '#number'
    And match response.data.status.name == '#string'

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
