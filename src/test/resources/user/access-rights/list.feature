@user @access_rights @positive
Feature: US Access-rights - list

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: GET access-rights returns the 12-code catalog
    Given path '/api/v1/user/access-rights'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[12]'
    And match response.data[*].code contains ['view', 'create', 'update', 'delete', 'grant', 'unlock']

  Scenario: 401 without a token
    Given path '/api/v1/user/access-rights'
    And header Authorization = null
    When method GET
    Then status 401
