@payment @severance_pays @positive
Feature: PAY-004 Severance Pay - Cancel

  Background:
    * url paymentUrl

  @smoke
  Scenario: Cancel PENDING record - returns 202 with CANCELLED status
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-20', terminationType: 'RESIGNATION', baseSalary: 1000.0, yearsOfService: 1.0, rate: 5.0, remark: 'Cancel PENDING record - returns 202 with CANCELLED status' }
    When method POST
    Then status 201
    * def createdId = response.data.id

    Given path '/api/v1/payment/severance-pays/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202
    And match response.error == null
    And match response.data.id == createdId
    And match response.data.status == 'CANCELLED'
    And match response.data.requestChangeId == '#number'
