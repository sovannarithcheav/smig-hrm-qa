@auth @security @negative
Feature: US account recovery validation

  Background:
    * url userUrl

  Scenario: forgot-password for an unknown user still returns 200 with no devToken (no existence leak)
    Given path '/api/v1/auth/forgot-password'
    And request { usernameOrEmail: 'no-such-user-xyz' }
    When method POST
    Then status 200
    And match response.data.status == 'ok'
    And match response.data.devToken == '#notpresent'

  Scenario: reset-password with a garbage token -> 400 RESET_TOKEN_INVALID
    Given path '/api/v1/auth/reset-password'
    And request { token: 'prt_not_a_real_token', newPassword: 'bB23456#' }
    When method POST
    Then status 400
    And match response.error == 'RESET_TOKEN_INVALID'

  Scenario: weak new password -> 400 WEAK_PASSWORD and does NOT consume the token
    Given path '/api/v1/auth/forgot-password'
    And request { usernameOrEmail: 'authorizer2' }
    When method POST
    Then status 200
    * def token = response.data.devToken

    # weak password rejected before the token is consumed
    Given path '/api/v1/auth/reset-password'
    And request { token: '#(token)', newPassword: 'short' }
    When method POST
    Then status 400
    And match response.error == 'WEAK_PASSWORD'

    # the same token still works -> reset back to the seed password (proves weak-check precedes markUsed)
    Given path '/api/v1/auth/reset-password'
    And request { token: '#(token)', newPassword: 'aA12345@' }
    When method POST
    Then status 200
    And match response.data.status == 'ok'
