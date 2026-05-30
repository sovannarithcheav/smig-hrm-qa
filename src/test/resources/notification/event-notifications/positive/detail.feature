@notification @event_notifications @positive
Feature: NT-EN-002 Get Event Notification by ID

  Background:
    * url notificationUrl

  @smoke
  Scenario: Get by ID returns correct shape
    Given path '/api/v1/notification/event-notifications/8'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == 8
    And match response.data.code == 'SALARY_PAID'
    And match response.data.name == '#string'
    And match response.data.type == '#string'
