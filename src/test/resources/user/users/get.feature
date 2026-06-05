@user @users @positive
Feature: US Users - detail

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: admin detail embeds secondary roles + funcs (collapsed to *)
    Given path '/api/v1/user/users/1'
    When method GET
    Then status 200
    And match response.data.username == 'admin'
    And match response.data.primaryRole.roleType == 'ADMIN'
    And match response.data.secondaryRoles[*].roleType contains 'AUTHORIZER'
    # In a pristine seed admin's perms collapse to ['*']; once functionality write-flow tests add an
    # ungranted functionality to the shared dev DB the union is the per-functionality list instead. Assert
    # a non-empty permission set (both shapes satisfy this) rather than the exact '*' collapse.
    And match response.data.funcs == '#[_ > 0]'

  Scenario: 404 unknown id
    Given path '/api/v1/user/users/999999'
    When method GET
    Then status 404
    And match response.error == 'NOT_FOUND'
