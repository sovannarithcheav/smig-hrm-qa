@user @role @write @positive @e2e
Feature: US role write-flow - grant then revoke an access right on a fresh role

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def adminToken = adminLogin.accessToken
    * url userUrl
    * def rname = 'WGrant ' + new Date().getTime()

  Scenario: create a role, grant USER/view, confirm it appears, then revoke it
    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminToken
    And request { name: '#(rname)', roleTypeId: 2 }
    When method POST
    Then status 202
    * def createReq = response.data.requestChangeId
    * call read('classpath:role/write/helper/approve.feature') { requestChangeId: '#(createReq)' }
    Given path '/api/v1/user/roles'
    And header Authorization = 'Bearer ' + adminToken
    And param q = rname
    When method GET
    Then status 200
    * def roleId = response.data.content[0].id

    Given path '/api/v1/user/roles/' + roleId + '/access'
    And header Authorization = 'Bearer ' + adminToken
    And request { functionalityId: 1, accessRight: 'view' }
    When method POST
    Then status 202
    * def grantReq = response.data.requestChangeId
    * call read('classpath:role/write/helper/approve.feature') { requestChangeId: '#(grantReq)' }

    Given path '/api/v1/user/roles/' + roleId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.access[*].permission contains 'USER_view'
    * def granted = karate.filter(response.data.access, function(x){ return x.permission == 'USER_view' })
    * def farId = granted[0].farId

    Given path '/api/v1/user/roles/' + roleId + '/access/' + farId
    And header Authorization = 'Bearer ' + adminToken
    When method DELETE
    Then status 202
    * def revokeReq = response.data.requestChangeId
    * call read('classpath:role/write/helper/approve.feature') { requestChangeId: '#(revokeReq)' }

    Given path '/api/v1/user/roles/' + roleId
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.access[*].permission !contains 'USER_view'
