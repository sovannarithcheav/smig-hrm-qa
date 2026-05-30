@notification @categories @positive
Feature: NT-CAT-001 List Categories

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns non-empty list with correct shape
    Given path '/api/v1/notification/categories'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    * assert response.data.length > 0

  @smoke
  Scenario: Contains seeded Payroll Management category
    Given path '/api/v1/notification/categories'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    When method GET
    Then status 200
    * def names = response.data.map(function(x){ return x.name })
    * assert names.indexOf('Payroll Management') >= 0
