@user @write @positive @e2e
Feature: US user write-flow - assign / set-primary / unassign role (set preserved)

  Background:
    * def uname = 'wrole' + new Date().getTime()
    # created with primary = 2 (HR), no secondaries
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: assign 3, promote 3 to primary (2 demoted), then unassign 2
    # --- assign role 3 as secondary ---
    Given path '/api/v1/user/users/' + userId + '/roles'
    And header Authorization = 'Bearer ' + adminToken
    And request { roleId: 3 }
    When method POST
    Then status 202
    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(response.data.requestChangeId)' }

    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.primaryRole.roleId == 2
    And match response.data.secondaryRoles[*].roleId contains 3

    # --- set primary to 3 (old primary 2 demoted to secondary, 3 removed from secondaries) ---
    Given path '/api/v1/user/users/' + userId + '/roles/3/primary'
    And header Authorization = 'Bearer ' + adminToken
    When method PUT
    Then status 202
    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(response.data.requestChangeId)' }

    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.primaryRole.roleId == 3
    And match response.data.secondaryRoles[*].roleId contains 2
    And match response.data.secondaryRoles[*].roleId !contains 3

    # --- unassign role 2 (now a secondary) ---
    Given path '/api/v1/user/users/' + userId + '/roles/2'
    And header Authorization = 'Bearer ' + adminToken
    When method DELETE
    Then status 202
    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(response.data.requestChangeId)' }

    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.primaryRole.roleId == 3
    And match response.data.secondaryRoles[*].roleId !contains 2
