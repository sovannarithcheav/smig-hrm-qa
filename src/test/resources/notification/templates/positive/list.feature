@notification @templates @positive
Feature: NT-001 List Notification Templates

  Background:
    * url notificationUrl

  @smoke
  Scenario: Happy path - returns paginated list with correct shape
    Given path '/api/v1/notification/templates'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.page == 0
    And match response.data.size == '#number'
    And match response.data.total == '#number'
    And match response.data.totalPages == '#number'
    And match response.data.content == '#[] #notnull'
    * assert response.data.total >= response.data.content.length

    # Assert every item in the list has the correct shape
    * def itemSchema = { id: '#number', name: '#string', body: '#string', subject: '##string', updatedAt: '##string', updatedBy: '##number', event: { id: '#number', code: '#string', name: '#string' }, channel: { id: '#number', name: '#string' }, status: { id: '#number', name: '#string' }, variables: '#array' }
    * match each response.data.content == itemSchema

    # Assert every variable inside every item has id and label
    * def varSchema = { id: '#number', label: '#string' }
    * karate.forEach(response.data.content, function(item){ karate.forEach(item.variables, function(v){ karate.match(v, varSchema) }) })

  @smoke
  Scenario: Filter by eventId - every item belongs to that event
    Given path '/api/v1/notification/templates'
    And param eventId = 1
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.content == '#[] #notnull'
    * assert response.data.total > 0
    * def ids = response.data.content.map(function(x){ return x.event.id })
    * karate.forEach(ids, function(id){ karate.match(id, 1) })

  @smoke
  Scenario: Filter by statusId - every item has that status
    Given path '/api/v1/notification/templates'
    And param statusId = 1
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.content == '#[] #notnull'
    * assert response.data.total > 0
    * def statusIds = response.data.content.map(function(x){ return x.status.id })
    * karate.forEach(statusIds, function(id){ karate.match(id, 1) })

  @smoke
  Scenario: Filter by eventId and statusId - every item matches both filters
    Given path '/api/v1/notification/templates'
    And param eventId = 1
    And param statusId = 1
    When method GET
    Then status 200
    And match response.error == null
    * def content = response.data.content
    * assert content.length > 0
    * karate.forEach(content, function(x){ karate.match(x.event.id, 1) })
    * karate.forEach(content, function(x){ karate.match(x.status.id, 1) })

  @smoke
  Scenario: Pagination - content length does not exceed requested size
    Given path '/api/v1/notification/templates'
    And param page = 0
    And param size = 5
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.page == 0
    And match response.data.size == 5
    * assert response.data.total >= response.data.content.length
    * assert response.data.content.length <= 5

  @smoke
  Scenario: Pagination page 1 - returns different set from page 0
    Given path '/api/v1/notification/templates'
    And param page = 0
    And param size = 5
    When method GET
    Then status 200
    * def page0Ids = response.data.content.map(function(x){ return x.id })

    Given path '/api/v1/notification/templates'
    And param page = 1
    And param size = 5
    When method GET
    Then status 200
    * def page1Ids = response.data.content.map(function(x){ return x.id })
    * def overlap = page0Ids.filter(function(id){ return page1Ids.indexOf(id) >= 0 })
    * assert overlap.length == 0
