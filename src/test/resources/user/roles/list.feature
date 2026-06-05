@user @roles @positive
Feature: US Roles - list

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  # total is >= 3, not == 3: role write-flow tests create extra roles in the shared dev DB.
  Scenario: list returns at least the 3 seed roles
    Given path '/api/v1/user/roles'
    When method GET
    Then status 200
    And match response.data.pagination.total == '#? _ >= 3'
    And match response.data.content[*].name contains ['ADMIN', 'HR Officer', 'Authorizer']

  Scenario: q filters by name
    Given path '/api/v1/user/roles'
    And param q = 'Officer'
    When method GET
    Then status 200
    And match response.data.pagination.total == 1
    And match response.data.content[0].name == 'HR Officer'
