@notification @audit_logs @positive
Feature: NT-AUD-001 List Audit Logs

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns array with correct shape
    Given path '/api/v1/notification/audit-logs'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Filter by userId returns matching logs
    Given path '/api/v1/notification/audit-logs'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    And param userId = userId
    When method GET
    Then status 200
    * def items = response.data
    * if (items.length > 0) assert items.filter(function(x){ return x.userId != userId }).length == 0
