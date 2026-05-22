@notification
Feature: NT-004 Event Notification Options (Dropdown)

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns list of {id, code, name} wrapped in {data, error}
    Given path '/api/v1/notification/event-notifications/options'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    And match each response.data == { id: '#number', code: '#string', name: '#string' }
