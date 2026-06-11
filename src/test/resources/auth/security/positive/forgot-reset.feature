@auth @security @write @positive
Feature: US account recovery — forgot-password then reset-password

  Background:
    * url userUrl

  Scenario: forgot -> reset with dev token; new password logs in; old refresh revoked; token single-use; restored
    # a live session whose refresh token must die when the password is reset
    * def pre = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }

    # request a reset (development returns the raw token)
    Given path '/api/v1/auth/forgot-password'
    And request { usernameOrEmail: 'authorizer2' }
    When method POST
    Then status 200
    And match response.data.status == 'ok'
    And match response.data.devToken == '#string'
    * def token = response.data.devToken

    # reset to a new password
    Given path '/api/v1/auth/reset-password'
    And request { token: '#(token)', newPassword: 'bB23456#' }
    When method POST
    Then status 200
    And match response.data.status == 'ok'

    # the pre-reset refresh token is revoked
    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(pre.refreshToken)' }
    When method POST
    Then status 401

    # the new password logs in
    * def after = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'bB23456#' }
    * match after.accessToken == '#string'

    # the same token cannot be reused
    Given path '/api/v1/auth/reset-password'
    And request { token: '#(token)', newPassword: 'cC34567$' }
    When method POST
    Then status 400
    And match response.error == 'RESET_TOKEN_INVALID'

    # FINAL: restore authorizer2 to the seed password via a fresh forgot->reset
    Given path '/api/v1/auth/forgot-password'
    And request { usernameOrEmail: 'authorizer2' }
    When method POST
    Then status 200
    * def token2 = response.data.devToken
    Given path '/api/v1/auth/reset-password'
    And request { token: '#(token2)', newPassword: 'aA12345@' }
    When method POST
    Then status 200
