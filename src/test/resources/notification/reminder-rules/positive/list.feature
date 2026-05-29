@notification @reminder-rules @positive
Feature: NT-RR-001 List Reminder Rules

  Background:
    * url notificationUrl

  @smoke
  Scenario: Happy path - returns array
    Given path '/api/v1/notification/reminder-rules'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
