@payment @severance_pays @negative
Feature: PAY-004 Severance Pay - Pay Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Pay a PENDING record (not yet approved) - returns 400
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1000.0, yearsOfService: 1.0, rate: 5.0, remark: 'Pay a PENDING record (not yet approved) - returns 400' }
    When method POST
    Then status 201
    * def createdId = response.data.id

    Given path '/api/v1/payment/severance-pays/' + createdId + '/pay'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error contains 'APPROVED'
    And match response.data == null

  @negative
  Scenario: Pay non-existent record - returns 400
    Given path '/api/v1/payment/severance-pays/999999999/pay'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Pay with non-numeric id - returns 400
    Given path '/api/v1/payment/severance-pays/abc/pay'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error != null
    And match response.data == null
