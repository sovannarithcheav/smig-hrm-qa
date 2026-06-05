@user @role @write @negative @e2e
Feature: US role write-flow - a rejected create is never applied (exercises lookup)

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * def rname = 'WReject ' + new Date().getTime()

  Scenario: submit create then reject -> the role is never written
    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And request { name: '#(rname)', roleTypeId: 2 }
    When method POST
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    * call read('classpath:role/write/helper/reject.feature') { requestChangeId: '#(requestChangeId)' }

    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And param q = rname
    When method GET
    Then status 200
    And match response.data.pagination.total == 0
