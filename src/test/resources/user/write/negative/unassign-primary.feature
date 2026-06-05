@user @write @negative
Feature: US user write-flow - cannot unassign a user's primary role

  Background:
    * def uname = 'wunp' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: unassigning the primary role (2) returns 422 RULE_VIOLATION at submit
    Given path '/api/v1/user/users/' + userId + '/roles/2'
    And header Authorization = 'Bearer ' + adminToken
    When method DELETE
    Then status 422
    And match response.error == 'RULE_VIOLATION'
    And match response.data == null
