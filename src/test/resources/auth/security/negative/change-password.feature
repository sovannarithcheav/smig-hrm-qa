@auth @security @negative
Feature: US change-password validation

  Background:
    * def a = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    * url userUrl

  Scenario: wrong old password -> 400 INVALID_OLD_PASSWORD (no change)
    Given path '/api/v1/auth/change-password'
    And header Authorization = 'Bearer ' + a.accessToken
    And request { oldPassword: 'wrongPass1#', newPassword: 'bB23456#' }
    When method POST
    Then status 400
    And match response.error == 'INVALID_OLD_PASSWORD'

  Scenario: weak new password -> 400 WEAK_PASSWORD (no change)
    Given path '/api/v1/auth/change-password'
    And header Authorization = 'Bearer ' + a.accessToken
    And request { oldPassword: 'aA12345@', newPassword: 'short' }
    When method POST
    Then status 400
    And match response.error == 'WEAK_PASSWORD'
