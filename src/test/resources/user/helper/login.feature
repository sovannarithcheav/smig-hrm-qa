@ignore
Feature: helper - obtain a US access token

  Scenario: login
    * url userUrl
    Given path '/api/v1/auth/login'
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 200
    * def accessToken = response.accessToken
