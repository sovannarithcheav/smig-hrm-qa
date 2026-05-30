@notification @subscriptions @positive
Feature: NT-SUB-001 List Subscriptions

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns array with correct shape
    Given path '/api/v1/notification/subscriptions'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
