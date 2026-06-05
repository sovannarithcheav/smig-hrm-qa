@user @users @positive
Feature: US Users - list

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: list returns the seed users with embedded primaryRole
    Given path '/api/v1/user/users'
    When method GET
    Then status 200
    # >= 4: the write-flow suite may have created additional users in the shared dev DB
    And match response.data.pagination.total == '#? _ >= 4'
    And match response.data.content[*].username contains ['admin', 'hr_user', 'authorizer', 'authorizer2']
    And match response.data.content[0].primaryRole.roleType == 'ADMIN'
    And match response.data.content[0].primaryRole.roleId == 1

  Scenario: q filters by username/fullName
    Given path '/api/v1/user/users'
    And param q = 'admin'
    When method GET
    Then status 200
    And match response.data.pagination.total == 1
    And match response.data.content[0].username == 'admin'

  Scenario: 401 without token
    Given path '/api/v1/user/users'
    And header Authorization = null
    When method GET
    Then status 401
