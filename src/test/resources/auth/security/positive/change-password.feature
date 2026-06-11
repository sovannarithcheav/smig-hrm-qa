@auth @security @write @positive
Feature: US change-password (direct) revokes all sessions

  Background:
    * url userUrl

  Scenario: correct old -> new logs in, old refresh revoked; restored to seed at end
    # login captures both tokens
    * def a = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }

    Given path '/api/v1/auth/change-password'
    And header Authorization = 'Bearer ' + a.accessToken
    And request { oldPassword: 'aA12345@', newPassword: 'bB23456#' }
    When method POST
    Then status 200
    And match response.data.status == 'ok'

    # the pre-change refresh token is now revoked
    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(a.refreshToken)' }
    When method POST
    Then status 401

    # the new password logs in
    * def b = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'bB23456#' }
    * match b.accessToken == '#string'

    # FINAL action: restore authorizer2 to the seed password (self-revokes b's session — do not reuse b after)
    Given path '/api/v1/auth/change-password'
    And header Authorization = 'Bearer ' + b.accessToken
    And request { oldPassword: 'bB23456#', newPassword: 'aA12345@' }
    When method POST
    Then status 200
