@user @write @negative
Feature: US user write-flow - cannot unassign a role the user does not hold

  Background:
    * def uname = 'wunh' + new Date().getTime()
    # primary = 2, no secondaries -> role 3 is not held
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: unassigning a non-held role (3) returns 422 RULE_VIOLATION at submit
    Given path '/api/v1/user/users/' + userId + '/roles/3'
    And header Authorization = 'Bearer ' + adminToken
    When method DELETE
    Then status 422
    And match response.error == 'RULE_VIOLATION'
    And match response.data == null
