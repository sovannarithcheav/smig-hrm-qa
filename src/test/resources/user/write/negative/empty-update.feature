@user @write @negative
Feature: US user write-flow - an update with no changed fields is rejected

  Background:
    * def uname = 'wemp' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: PUT with an empty body returns 400 VALIDATION_ERROR (no CS request)
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    And request {}
    When method PUT
    Then status 400
    And match response.error == 'VALIDATION_ERROR'
    And match response.data == null
