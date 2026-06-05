@user @role @write @negative
Feature: US role write-flow - deactivating an in-use primary role is rejected

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl

  Scenario: role 2 (HR Officer) is hr_user's primary -> 422 RULE_VIOLATION, no CS request
    Given path '/api/v1/user/roles/2/deactivate'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    When method POST
    Then status 422
    And match response.error == 'RULE_VIOLATION'
    And match response.data == null
