@user @write @positive @e2e
Feature: US user write-flow - deactivate

  Background:
    * def uname = 'wdeact' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: deactivate flips status to DEACTIVATED only after approval
    Given path '/api/v1/user/users/' + userId + '/deactivate'
    And header Authorization = 'Bearer ' + adminToken
    When method POST
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    # still ACTIVE before approval
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.status == 'ACTIVE'

    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(requestChangeId)' }
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.status == 'DEACTIVATED'
