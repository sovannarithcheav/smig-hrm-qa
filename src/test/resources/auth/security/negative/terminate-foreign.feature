@auth @security @negative
Feature: US self-terminate of a foreign session is a 404 (no leak)

  Background:
    * url userUrl

  Scenario: authorizer2 cannot terminate admin's session -> 404
    * def adminS = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    # admin's own newest session id
    Given path '/api/v1/auth/sessions'
    And header Authorization = 'Bearer ' + adminS.accessToken
    When method GET
    Then status 200
    * def adminSessionId = response.data.content[0].id

    * def a = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    Given path '/api/v1/auth/sessions/' + adminSessionId + '/terminate'
    And header Authorization = 'Bearer ' + a.accessToken
    When method POST
    Then status 404

  Scenario: terminating an already-terminated session is idempotent (200, not 404)
    * def b = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    Given path '/api/v1/auth/sessions'
    And header Authorization = 'Bearer ' + b.accessToken
    When method GET
    Then status 200
    * def sid = response.data.content[0].id
    Given path '/api/v1/auth/sessions/' + sid + '/terminate'
    And header Authorization = 'Bearer ' + b.accessToken
    When method POST
    Then status 200
    # second terminate of the same id -> still 200 (idempotent), needs a fresh token since b's session is now revoked
    * def c = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    Given path '/api/v1/auth/sessions/' + sid + '/terminate'
    And header Authorization = 'Bearer ' + c.accessToken
    When method POST
    Then status 200
