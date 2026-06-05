@user @write @negative @e2e
Feature: US user write-flow - a rejected request leaves state unchanged (exercises lookup)

  Background:
    * def uname = 'wrej' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: submit deactivate then reject -> user stays ACTIVE
    Given path '/api/v1/user/users/' + userId + '/deactivate'
    And header Authorization = 'Bearer ' + adminToken
    When method POST
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    # CS reject snapshots the current row via the receiver's lookup, then finalizes without applying
    * call read('classpath:user/write/helper/reject.feature') { requestChangeId: '#(requestChangeId)' }

    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.status == 'ACTIVE'
