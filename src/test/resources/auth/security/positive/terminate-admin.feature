@auth @security @write @positive
Feature: US admin session terminate + terminate-all

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def adminToken = adminLogin.accessToken
    * url userUrl

  Scenario: admin terminates one session by id; its refresh dies
    * def c = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    * def authId = c.user.id
    # newest session for authorizer2 is c
    Given path '/api/v1/user/sessions'
    And header Authorization = 'Bearer ' + adminToken
    And param userId = authId
    When method GET
    Then status 200
    * def cSessionId = response.data.content[0].id

    Given path '/api/v1/user/sessions/' + cSessionId + '/terminate'
    And header Authorization = 'Bearer ' + adminToken
    When method POST
    Then status 200

    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(c.refreshToken)' }
    When method POST
    Then status 401

  Scenario: admin terminate-all kills every active session for the user
    * def d = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    * def e = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    * def authId = d.user.id

    Given path '/api/v1/user/users/' + authId + '/sessions/terminate-all'
    And header Authorization = 'Bearer ' + adminToken
    When method POST
    Then status 200
    And match response.data.status == 'ok'
    And assert response.data.count >= 2

    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(d.refreshToken)' }
    When method POST
    Then status 401

    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(e.refreshToken)' }
    When method POST
    Then status 401
