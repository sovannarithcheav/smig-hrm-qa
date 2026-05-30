@notification @history @negative
Feature: NT-HIS-N-001 Mark As Read — not found

  Background:
    * url notificationUrl

  Scenario: Unknown notification ID returns 404
    Given path '/api/v1/notification/history/999999/read'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method POST
    Then status 404
