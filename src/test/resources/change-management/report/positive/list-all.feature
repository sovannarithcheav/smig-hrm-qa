@change-management @report @positive
Feature: RC-RPT-001 Request Change Report - List All (for admins)

  Background:
    * url changeManagementUrl

  @smoke
  Scenario: Happy path - returns paged response with content array
    Given path '/api/v1/request-change/report/for/admins'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.content == '#array'
    And match response.data.totalElements == '#number'
    And match response.data.page == 0
    And match response.data.size == '#number'
    And match response.data.totalPages == '#number'

  @smoke
  Scenario: Each item has required fields when data exists
    Given path '/api/v1/request-change/report/for/admins'
    When method GET
    Then status 200
    * def items = response.data.content
    * if (items.length > 0) karate.match(items[0], { id: '#number', subject: '#string', action: '#string', statusId: '#number', statusName: '#string', requestedBy: '#number', participant: '#number', requestedAt: '#string', totalAuthorizer: '#number', numResponse: '#number' })

  @smoke
  Scenario: Filter by subject returns only authorizer-setting items
    Given path '/api/v1/request-change/report/for/admins'
    And param subject = 'authorizer-setting'
    When method GET
    Then status 200
    And match response.error == null
    * def items = response.data.content
    * def allMatch = function(arr){ return arr.every(function(x){ return x.subject == 'authorizer-setting' }) }
    * assert allMatch(items)

  @smoke
  Scenario: Filter by unknown subject returns empty content
    Given path '/api/v1/request-change/report/for/admins'
    And param subject = 'nonexistent-subject-xyz'
    When method GET
    Then status 200
    And match response.data.content == '#[0]'
    And match response.data.totalElements == 0

  @smoke
  Scenario: Pagination - size parameter is respected
    Given path '/api/v1/request-change/report/for/admins'
    And param size = 2
    When method GET
    Then status 200
    And match response.data.size == 2
    And match response.data.content == '#[_ <= 2]'
