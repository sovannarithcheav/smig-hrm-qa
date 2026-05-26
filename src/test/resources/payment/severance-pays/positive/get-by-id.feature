@payment @severance_pays @positive
Feature: PAY-004 Severance Pay - Get by ID

  Background:
    * url paymentUrl

  @smoke
  Scenario: Get by ID - returns the created record
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-15', terminationType: 'RESIGNATION', baseSalary: 1200.0, yearsOfService: 2.0, rate: 6.0, remark: 'Get by ID - returns the created record' }
    When method POST
    Then status 201
    * def createdId = response.data.id

    Given path '/api/v1/payment/severance-pays/' + createdId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == createdId
    And match response.data.employeeId == empId
    And match response.data.terminationType == 'RESIGNATION'
    And match response.data.status == 'PENDING'
