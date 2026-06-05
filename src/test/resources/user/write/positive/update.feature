@user @write @positive @e2e
Feature: US user write-flow - update profile (email/fullName)

  Background:
    * def uname = 'wupd' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: update changes email + fullName only after approval
    # submit update
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    And request { email: 'updated@smig', fullName: 'Updated Name' }
    When method PUT
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    # not changed before approval
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.fullName == 'QA Throwaway'

    # approve + verify
    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(requestChangeId)' }
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.fullName == 'Updated Name'
    And match response.data.email == 'updated@smig'
