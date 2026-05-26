@notification @templates @negative
Feature: NT-001 List Notification Templates - Negative

  Background:
    * url notificationUrl

  @negative
  Scenario: No matching eventId - returns empty content with total 0
    Given path '/api/v1/notification/templates'
    And param eventId = 999999
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.content == '#[0]'
    And match response.data.total == 0
