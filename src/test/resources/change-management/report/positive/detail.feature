@change-management @report @positive
Feature: RC-RPT-003 Request Change Report - Detail and Status Enums

  Background:
    * url changeManagementUrl
    * def setup = callonce read('classpath:change-management/report/helper/pick-any-id.feature')
    * def anyId = setup.anyId

  @smoke
  Scenario: Happy path - returns full detail for an existing request
    * def skip = anyId == null
    * if (skip) karate.abort()
    Given path '/api/v1/request-change/report/' + anyId + '/detail'
    When method GET
    Then status 200
    And match response.data.id == anyId
    And match response.data.subject == '#string'
    And match response.data.action == '#string'
    And match response.data.statusId == '#number'
    And match response.data.statusName == '#string'
    And match response.data.requestedBy == '#number'
    And match response.data.participant == '#number'
    And match response.data.requestedAt == '#string'
    And match response.data.approvals == '#array'
    And match response.data.requestObject == '#notnull'

  @smoke
  Scenario: Request status enums returns array of statuses
    Given path '/api/v1/request-change/report/statuses/request'
    When method GET
    Then status 200
    And match response.data == '#array'
    And match response.data[0] contains { id: '#number', name: '#string' }

  @smoke
  Scenario: Authorize status enums returns array of statuses
    Given path '/api/v1/request-change/report/statuses/authorize'
    When method GET
    Then status 200
    And match response.data == '#array'
    And match response.data[0] contains { id: '#number', name: '#string' }
