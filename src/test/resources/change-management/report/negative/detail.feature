@change-management @report @negative
Feature: RC-RPT-N-001 Request Change Report - not found

  Background:
    * url changeManagementUrl

  Scenario: Unknown id on detail returns 400 with error
    Given path '/api/v1/request-change/report/999999/detail'
    When method GET
    Then status 400
    And match response.error != null
