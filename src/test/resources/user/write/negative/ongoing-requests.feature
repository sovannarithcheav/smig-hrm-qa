@user @write @negative
Feature: US user write-flow - a second non-final request for the same user is rejected by CS

  Background:
    * def uname = 'wong' + new Date().getTime()
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId
    * def adminToken = created.adminToken
    * url userUrl

  Scenario: second update while one is still pending returns 400 ONGOING_REQUESTS
    # first update — left pending (not approved)
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    And request { fullName: 'First Pending' }
    When method PUT
    Then status 202
    * def firstRcId = response.data.requestChangeId

    # second update on the same user — CS rejects the duplicate in-flight request
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    And request { fullName: 'Second Blocked' }
    When method PUT
    Then status 400
    And match response.error == 'ONGOING_REQUESTS'

    # clear the pending request so state is consistent
    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(firstRcId)' }
    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.fullName == 'First Pending'
