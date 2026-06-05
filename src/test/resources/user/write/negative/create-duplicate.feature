@user @write @negative
Feature: US user write-flow - create with a duplicate username is rejected at submit

  Background:
    * def uname = 'wdup' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: submitting create for an existing username returns 409 USERNAME_TAKEN (no CS request)
    Given path '/api/v1/user/users'
    And header Authorization = 'Bearer ' + adminToken
    And request { username: '#(uname)', primaryRoleId: 2 }
    When method POST
    Then status 409
    And match response.error == 'USERNAME_TAKEN'
    And match response.data == null
