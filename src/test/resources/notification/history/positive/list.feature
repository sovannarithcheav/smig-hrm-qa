@notification @history @positive
Feature: NT-HIS-001 List Notification History

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns array with correct shape
    Given path '/api/v1/notification/history'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Filter by read=false returns only unread items
    Given path '/api/v1/notification/history'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    And param read = false
    When method GET
    Then status 200
    * def items = response.data
    * if (items.length > 0) assert items.filter(function(x){ return x.read == true }).length == 0
