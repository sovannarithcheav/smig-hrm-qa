@user @functionality @write @negative
Feature: US functionality write-flow - duplicate code is rejected at submit

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl

  Scenario: submitting create for the seeded code USER returns 409 CODE_TAKEN
    Given path '/api/v1/user/functionalities'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And request { code: 'USER', name: 'Dup', module: 'USER', accessRights: [] }
    When method POST
    Then status 409
    And match response.error == 'CODE_TAKEN'
    And match response.data == null
