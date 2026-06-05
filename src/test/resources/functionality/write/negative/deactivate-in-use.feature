@user @functionality @write @negative
Feature: US functionality write-flow - deactivating a granted functionality is rejected

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl

  Scenario: functionality 1 (USER) has FARs granted to the ADMIN role -> 422 FUNCTIONALITY_IN_USE
    Given path '/api/v1/user/functionalities/1/deactivate'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    When method POST
    Then status 422
    And match response.error == 'FUNCTIONALITY_IN_USE'
    And match response.data == null
