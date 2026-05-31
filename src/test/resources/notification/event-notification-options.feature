@notification
Feature: NT-004 Event Notification Options (Dropdown)

  Background:
    * url notificationUrl

  @smoke
  Scenario: Returns non-empty list with correct field shape
    Given path '/api/v1/notification/event-notifications/options'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    * assert response.data.length > 0
    And match each response.data == { id: '#number', code: '#string', name: '#string' }

  @smoke
  Scenario: All ids are positive and unique
    Given path '/api/v1/notification/event-notifications/options'
    When method GET
    Then status 200
    * def ids = response.data.map(function(x){ return x.id })
    * assert ids.filter(function(id){ return id <= 0 }).length == 0
    * def isUnique = function(arr){ return arr.length == arr.filter(function(v,i,a){ return a.indexOf(v) === i }).length }
    * assert isUnique(ids)

  @smoke
  Scenario: All codes are unique and non-blank
    Given path '/api/v1/notification/event-notifications/options'
    When method GET
    Then status 200
    * def codes = response.data.map(function(x){ return x.code })
    * assert codes.filter(function(code){ return code.trim().length == 0 }).length == 0
    * def isUnique = function(arr){ return arr.length == arr.filter(function(v,i,a){ return a.indexOf(v) === i }).length }
    * assert isUnique(codes)
