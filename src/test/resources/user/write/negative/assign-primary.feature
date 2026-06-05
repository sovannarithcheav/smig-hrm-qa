@user @write @negative
Feature: US user write-flow - cannot assign a user's own primary role as a secondary

  Background:
    * def uname = 'wasp' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: assigning roleId == primary (2) returns 422 RULE_VIOLATION at submit
    Given path '/api/v1/user/users/' + userId + '/roles'
    And header Authorization = 'Bearer ' + adminToken
    And request { roleId: 2 }
    When method POST
    Then status 422
    And match response.error == 'RULE_VIOLATION'
    And match response.data == null
