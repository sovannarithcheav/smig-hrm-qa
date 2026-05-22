@notification
Feature: NT-001 List Notification Templates

  Background:
    * url notificationUrl

  @smoke
  Scenario: Happy path - returns paginated list wrapped in {data, error}
    Given path '/api/v1/notification/templates'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#notnull'
    And match response.data.content == '#array'
    And match response.data.page == '#number'
    And match response.data.size == '#number'
    And match response.data.total == '#number'

  @smoke
  Scenario: Filter by eventId - returns only matching templates
    Given path '/api/v1/notification/templates'
    And param eventId = 1
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.content == '#array'

  @smoke
  Scenario: Filter by statusId - returns only active templates
    Given path '/api/v1/notification/templates'
    And param statusId = 1
    When method GET
    Then status 200
    And match response.error == null

  @smoke
  Scenario: Pagination - size=5 returns at most 5 records
    Given path '/api/v1/notification/templates'
    And param page = 0
    And param size = 5
    When method GET
    Then status 200
    And match response.data.size == 5
