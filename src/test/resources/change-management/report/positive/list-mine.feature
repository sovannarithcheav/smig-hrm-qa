@change-management @report @positive
Feature: RC-RPT-002 Request Change Report - List Mine (for requesters)

  Background:
    * url changeManagementUrl

  @smoke
  Scenario: Happy path - returns paged response for the requester
    Given path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.content == '#array'
    And match response.data.totalElements == '#number'
    And match response.data.page == 0

  @smoke
  Scenario: All returned items belong to the requesting user
    Given path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    When method GET
    Then status 200
    * def userIdInt = parseInt(userId)
    * def allMine = function(arr){ return arr.every(function(x){ return x.requestedBy == userIdInt }) }
    * assert allMine(response.data.content)

  @smoke
  Scenario: Different user sees different (or empty) results
    Given path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = '9999'
    When method GET
    Then status 200
    And match response.data.totalElements == 0

  @smoke
  Scenario: Missing X-User-Id header returns 400
    Given path '/api/v1/request-change/report/for/requesters'
    When method GET
    Then status 400
