@user @sessions @positive
Feature: US Sessions - list

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: list returns sessions with pagination envelope
    Given path '/api/v1/user/sessions'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.pagination.total == '#number'
    And assert response.data.pagination.total >= 1

  Scenario: filter by userId returns only that user's sessions
    Given path '/api/v1/user/sessions'
    And param userId = 1
    When method GET
    Then status 200
    And match each response.data.content[*].userId == 1
