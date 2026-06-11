@auth @security @write @positive @e2e
Feature: US admin reset-password sets must_change_password (direct)

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def adminToken = adminLogin.accessToken
    * url userUrl
    * def uname = 'wreset' + new Date().getTime()

  Scenario: create a disposable user via CS, admin-reset it -> 200 + must_change_password=true
    * def created = call read('classpath:user/write/helper/create-user.feature') { username: '#(uname)', primaryRoleId: 2 }
    * def userId = created.createdUserId

    Given path '/api/v1/user/users/' + userId + '/reset-password'
    And header Authorization = 'Bearer ' + adminToken
    When method POST
    Then status 200
    And match response.data.status == 'ok'

    Given path '/api/v1/user/users/' + userId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.mustChangePassword == true
