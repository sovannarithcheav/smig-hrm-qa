@user @functionality @write @create @positive @e2e
Feature: US functionality write-flow - create with access rights (submit -> 202 -> approve)

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def adminToken = adminLogin.accessToken
    * url userUrl
    * def fcode = 'WF' + new Date().getTime()

  Scenario: create forwards to CS (202, no row), approval applies an ACTIVE functionality with FARs
    Given path '/api/v1/user/functionalities'
    And header Authorization = 'Bearer ' + adminToken
    And request { code: '#(fcode)', name: 'QA Feature', module: 'QA', accessRights: ['view','create'] }
    When method POST
    Then status 202
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    Given path '/api/v1/user/functionalities'
    And header Authorization = 'Bearer ' + adminToken
    And param q = fcode
    When method GET
    Then status 200
    And match response.data.pagination.total == 0

    * call read('classpath:functionality/write/helper/approve.feature') { requestChangeId: '#(requestChangeId)' }

    Given path '/api/v1/user/functionalities'
    And header Authorization = 'Bearer ' + adminToken
    And param q = fcode
    When method GET
    Then status 200
    And match response.data.pagination.total == 1
    And match response.data.content[0].code == fcode
    And match response.data.content[0].status == 'ACTIVE'
    * def fid = response.data.content[0].id

    Given path '/api/v1/user/functionalities/' + fid
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.accessRights contains 'view'
    And match response.data.accessRights contains 'create'
