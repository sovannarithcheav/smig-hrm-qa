@user @write @create @positive @e2e
Feature: US user write-flow - create (submit -> 202 -> approve -> ACTIVE)

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * def uname = 'wuser' + new Date().getTime()

  Scenario: create forwards to CS (202, no row), and the approval applies an ACTIVE user
    # submit
    Given path '/api/v1/user/users'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And request { username: '#(uname)', email: 'wuser@smig', fullName: 'Write User', primaryRoleId: 2, secondaryRoleIds: [3] }
    When method POST
    Then status 202
    And match response.data.requestChangeId == '#number'
    And match response.error == null
    * def requestChangeId = response.data.requestChangeId

    # nothing written before approval
    Given path '/api/v1/user/users'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And param q = uname
    When method GET
    Then status 200
    And match response.data.pagination.total == 0

    # approve via CS (synchronous callback applies the row)
    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(requestChangeId)' }

    # the user now exists, ACTIVE, must change the temp password
    Given path '/api/v1/user/users'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And param q = uname
    When method GET
    Then status 200
    And match response.data.pagination.total == 1
    And match response.data.content[0].username == uname
    And match response.data.content[0].status == 'ACTIVE'
    And match response.data.content[0].mustChangePassword == true
    And match response.data.content[0].primaryRole.roleId == 2
    * def newId = response.data.content[0].id

    # detail carries the secondary role + a non-empty permission set
    Given path '/api/v1/user/users/' + newId
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    When method GET
    Then status 200
    And match response.data.secondaryRoles[*].roleId contains 3
    And match response.data.funcs == '#[_ > 0]'
