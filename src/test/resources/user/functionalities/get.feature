@user @functionalities @positive
Feature: US Functionalities - detail

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  Scenario: detail embeds applicable access-rights
    Given path '/api/v1/user/functionalities/1'
    When method GET
    Then status 200
    And match response.data.code == 'USER'
    And match response.data.name == 'User Management'
    And match response.data.module == 'USER'
    And match response.data.accessRights contains ['view', 'create', 'update', 'delete', 'assign', 'reset', 'unlock']

  Scenario: 404 unknown id
    Given path '/api/v1/user/functionalities/999999'
    When method GET
    Then status 404
    And match response.error == 'NOT_FOUND'
