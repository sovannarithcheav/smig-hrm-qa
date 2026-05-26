@payment @severance_pays @positive @e2e
Feature: PAY-004 Severance Pay - E2E Create + Approve + Mark Paid

  Background:
    * url paymentUrl

  Scenario: Create → approve via CS → mark paid - status becomes PAID
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending

    * print '=== STEP 1: Create severance pay ==='
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-08-01', terminationType: 'RETIREMENT', baseSalary: 3000.0, yearsOfService: 6.0, rate: 9.0, remark: 'Create → approve via CS → mark paid - status becomes PAID' }
    When method POST
    Then status 201
    * def createdId = response.data.id
    * def requestChangeId = response.data.requestChangeId

    * print '=== STEP 2: Approve via Change Management Service ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    * karate.pause(1000)

    * print '=== STEP 3: Verify APPROVED ==='
    * url paymentUrl
    Given path '/api/v1/payment/severance-pays/' + createdId
    When method GET
    Then status 200
    And match response.data.status == 'APPROVED'

    * print '=== STEP 4: Mark as paid ==='
    Given path '/api/v1/payment/severance-pays/' + createdId + '/pay'
    And header X-User-Id = userId
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.id == createdId
    And match response.data.status == 'PAID'
