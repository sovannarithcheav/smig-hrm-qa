@user @role @write @create @positive @e2e
Feature: US role write-flow - create (submit -> 202 -> approve -> ACTIVE)

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * def rname = 'WRole ' + new Date().getTime()

  Scenario: create forwards to CS (202, no row), and approval applies an ACTIVE role
    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And request { name: '#(rname)', roleTypeId: 2, description: 'created by qa' }
    When method POST
    Then status 202
    And match response.data.requestChangeId == '#number'
    And match response.error == null
    * def requestChangeId = response.data.requestChangeId

    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And param q = rname
    When method GET
    Then status 200
    And match response.data.pagination.total == 0

    * call read('classpath:role/write/helper/approve.feature') { requestChangeId: '#(requestChangeId)' }

    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And param q = rname
    When method GET
    Then status 200
    And match response.data.pagination.total == 1
    And match response.data.content[0].name == rname
    And match response.data.content[0].status == 'ACTIVE'
    And match response.data.content[0].roleType.roleId == 2
