@ignore
Feature: helper - reject a request-change as the authorizer

  Scenario: reject
    * def authLogin = call read('classpath:user/helper/login.feature') { username: 'authorizer', password: 'aA12345@' }
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/reject'
    And header Authorization = 'Bearer ' + authLogin.accessToken
    And request { authorizerRemark: 'qa reject' }
    When method POST
    Then status 200
