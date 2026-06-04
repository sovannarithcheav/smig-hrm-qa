@user @sessions @positive
Feature: US Sessions - detail

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: detail by id (take an id from the list)
    Given path '/api/v1/user/sessions'
    And param userId = 1
    When method GET
    Then status 200
    * def sid = response.data.content[0].id
    Given path '/api/v1/user/sessions/' + sid
    And header Authorization = 'Bearer ' + login.accessToken
    When method GET
    Then status 200
    And match response.data.id == sid
    And match response.data.userId == 1
    And match response.data.status == 'ACTIVE'

  Scenario: 404 unknown id
    Given path '/api/v1/user/sessions/999999'
    When method GET
    Then status 404
    And match response.error == 'NOT_FOUND'
