@auth @security @write @positive
Feature: US admin unlock clears a lockout (direct)

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def adminToken = adminLogin.accessToken
    * url userUrl
    # authorizer2's id (its primary role is 3). Resolve by username filter.
    * def find = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    * def authId = find.user.id

  Scenario: 5 bad logins (401 each, 5th locks) then 6th -> 423; admin unlock -> login works again
    # 5 wrong-password attempts; the 5th sets locked_until but login still returns 401 (lock checked before verify)
    * def bad = { username: 'authorizer2', password: 'nope-wrong-1' }
    Given path '/api/v1/auth/login'
    And request bad
    When method POST
    Then status 401
    Given path '/api/v1/auth/login'
    And request bad
    When method POST
    Then status 401
    Given path '/api/v1/auth/login'
    And request bad
    When method POST
    Then status 401
    Given path '/api/v1/auth/login'
    And request bad
    When method POST
    Then status 401
    Given path '/api/v1/auth/login'
    And request bad
    When method POST
    Then status 401
    # 6th request now hits the lock check first -> 423
    Given path '/api/v1/auth/login'
    And request bad
    When method POST
    Then status 423
    And match response.error == 'ACCOUNT_LOCKED'

    # admin unlocks
    Given path '/api/v1/user/users/' + authId + '/unlock'
    And header Authorization = 'Bearer ' + adminToken
    When method POST
    Then status 200
    And match response.data.status == 'ok'

    # login works again with the seed password (proves lock + failed_attempts cleared)
    Given path '/api/v1/auth/login'
    And request { username: 'authorizer2', password: 'aA12345@' }
    When method POST
    Then status 200
