@notification @history @positive
Feature: NT-HIS-003 Mark As Read

  Background:
    * url notificationUrl

  @smoke
  Scenario: Mark all as read returns updated count
    Given path '/api/v1/notification/history/read-all'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.updated == '#number'

  @smoke
  Scenario: After mark-all-read unread count is zero
    Given path '/api/v1/notification/history/unread-count'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    And match response.data.count == 0
