@user @role @write @negative
Feature: US role write-flow - duplicate role name is rejected at submit

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl

  Scenario: submitting create for an existing role name returns 409 ROLE_NAME_TAKEN
    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And request { name: 'HR Officer', roleTypeId: 2 }
    When method POST
    Then status 409
    And match response.error == 'ROLE_NAME_TAKEN'
    And match response.data == null
