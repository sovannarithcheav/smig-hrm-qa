@ignore
Feature: helper - approve a request-change as the authorizer (quorum = 1)

  Scenario: approve
    * def authLogin = call read('classpath:user/helper/login.feature') { username: 'authorizer', password: 'aA12345@' }
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header Authorization = 'Bearer ' + authLogin.accessToken
    And request {}
    When method POST
    Then status 200
