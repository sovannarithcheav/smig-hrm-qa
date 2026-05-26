@payment @severance_pays @positive @e2e
Feature: PAY-004 Severance Pay - E2E Create + CS Approval

  Background:
    * url paymentUrl

  Scenario: Create severance pay then approve via CS - record becomes APPROVED
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending

    * print '=== STEP 1: Create severance pay via payment service ==='
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-07-15', terminationType: 'RESIGNATION', baseSalary: 2500.0, yearsOfService: 4.0, rate: 8.0, remark: 'Create severance pay then approve via CS - record becomes APPROVED' }
    When method POST
    Then status 201
    And match response.data.status == 'PENDING'
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

    * print '=== STEP 3: Verify record is APPROVED ==='
    * url paymentUrl
    Given path '/api/v1/payment/severance-pays/' + createdId
    When method GET
    Then status 200
    And match response.data.status == 'APPROVED'
    And match response.data.confirmedBy == '#number'
