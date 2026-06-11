@auth @security @write @positive
Feature: US self session-terminate revokes that session only

  Background:
    * url userUrl

  Scenario: two logins, terminate the older (A), its refresh dies, the newer (B) survives
    * def a = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }
    * def b = call read('classpath:user/helper/login.feature') { username: 'authorizer2', password: 'aA12345@' }

    # list is ordered id DESC: content[0]=B (newest), content[1]=A (older)
    Given path '/api/v1/auth/sessions'
    And header Authorization = 'Bearer ' + b.accessToken
    When method GET
    Then status 200
    And assert response.data.content.length >= 2
    * def sessionAId = response.data.content[1].id

    Given path '/api/v1/auth/sessions/' + sessionAId + '/terminate'
    And header Authorization = 'Bearer ' + b.accessToken
    When method POST
    Then status 200
    And match response.data.status == 'ok'

    # A's refresh now 401, B's refresh still 200
    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(a.refreshToken)' }
    When method POST
    Then status 401

    Given path '/api/v1/auth/refresh'
    And request { refreshToken: '#(b.refreshToken)' }
    When method POST
    Then status 200
