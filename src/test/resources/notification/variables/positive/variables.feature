@notification
Feature: NT-005 Notification Variables

  Background:
    * url notificationUrl

  @smoke
  Scenario: List all - returns non-empty list with correct shape
    Given path '/api/v1/notification/variables'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    * assert response.data.length > 0
    And match each response.data == { id: '#number', name: '#string', label: '#string' }

  @smoke
  Scenario: List all - ids are positive and unique, names are unique and in placeholder format
    Given path '/api/v1/notification/variables'
    When method GET
    Then status 200
    * def ids   = response.data.map(function(x){ return x.id })
    * def names = response.data.map(function(x){ return x.name })
    * assert ids.filter(function(id){ return id <= 0 }).length == 0
    * def isUnique = function(arr){ return arr.length == arr.filter(function(v,i,a){ return a.indexOf(v) === i }).length }
    * assert isUnique(ids)
    * assert isUnique(names)
    * assert names.filter(function(n){ return !n.startsWith('${') || !n.endsWith('}') }).length == 0

  @smoke
  Scenario: Get by id - returns correct variable matching list data
    # Fetch first variable from list dynamically
    Given path '/api/v1/notification/variables'
    When method GET
    Then status 200
    * def expected = response.data[0]

    Given path '/api/v1/notification/variables/' + expected.id
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == expected.id
    And match response.data.name == expected.name
    And match response.data.label == expected.label

  @smoke
  Scenario: Get by eventCode - returns variables associated with that event
    Given path '/api/v1/notification/events/PWD_RESET_SUCC/variables'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    * assert response.data.length > 0
    And match each response.data == { id: '#number', name: '#string', label: '#string' }
