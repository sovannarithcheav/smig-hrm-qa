@notification @history @positive
Feature: NT-HIS-002 Unread Count

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns a non-negative count
    Given path '/api/v1/notification/history/unread-count'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.count == '#number'
    * assert response.data.count >= 0
