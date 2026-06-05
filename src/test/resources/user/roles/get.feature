@user @roles @positive
Feature: US Roles - detail

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: ADMIN role detail embeds granted access (all 40 FAR)
    Given path '/api/v1/user/roles/1'
    When method GET
    Then status 200
    And match response.data.name == 'ADMIN'
    And match response.data.roleType.roleType == 'ADMIN'
    And match response.data.roleType.name == 'Administrator'
    And match response.data.roleType.roleId == 1
    And match response.data.access == '#[40]'
    And match response.data.access[*].permission contains ['USER_view', 'USER_create', 'ROLE_view']

  Scenario: 404 unknown id
    Given path '/api/v1/user/roles/999999'
    When method GET
    Then status 404
    And match response.error == 'NOT_FOUND'
