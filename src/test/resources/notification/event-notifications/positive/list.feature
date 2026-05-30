@notification @event_notifications @positive
Feature: NT-EN-001 List Event Notifications

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns non-empty list with correct shape
    Given path '/api/v1/notification/event-notifications'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    * assert response.data.length > 0
    And match each response.data contains { id: '#number', code: '#string', name: '#string', type: '#string' }

  @smoke
  Scenario: Contains seeded SALARY_PAID event
    Given path '/api/v1/notification/event-notifications'
    When method GET
    Then status 200
    * def codes = response.data.map(function(x){ return x.code })
    * assert codes.indexOf('SALARY_PAID') >= 0
