@user @functionality @write @positive @e2e
Feature: US functionality write-flow - update reconciles the FAR set

  Background:
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def adminToken = adminLogin.accessToken
    * url userUrl
    * def fcode = 'WFU' + new Date().getTime()

  Scenario: create with [view], then update to [view, update] -> FAR set becomes both
    Given path '/api/v1/user/functionalities'
    And header Authorization = 'Bearer ' + adminToken
    And request { code: '#(fcode)', name: 'QA Reconcile', module: 'QA', accessRights: ['view'] }
    When method POST
    Then status 202
    * def createReq = response.data.requestChangeId
    * call read('classpath:functionality/write/helper/approve.feature') { requestChangeId: '#(createReq)' }
    Given path '/api/v1/user/functionalities'
    And header Authorization = 'Bearer ' + adminToken
    And param q = fcode
    When method GET
    Then status 200
    * def fid = response.data.content[0].id

    Given path '/api/v1/user/functionalities/' + fid
    And header Authorization = 'Bearer ' + adminToken
    And request { accessRights: ['view','update'] }
    When method PUT
    Then status 202
    * def updReq = response.data.requestChangeId
    * call read('classpath:functionality/write/helper/approve.feature') { requestChangeId: '#(updReq)' }

    Given path '/api/v1/user/functionalities/' + fid
    And header Authorization = 'Bearer ' + adminToken
    When method GET
    Then status 200
    And match response.data.accessRights contains 'view'
    And match response.data.accessRights contains 'update'
