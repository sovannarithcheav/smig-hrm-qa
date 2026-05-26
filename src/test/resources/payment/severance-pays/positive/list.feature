@payment @severance_pays @positive
Feature: PAY-004 Severance Pay - List

  Background:
    * url paymentUrl

  @smoke
  Scenario: List severance pays - returns array with correct item schema
    Given path '/api/v1/payment/severance-pays'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    * def itemSchema = { id: '#number', employeeId: '#number', terminationDate: '#string', terminationType: '#string', baseSalary: '#number', yearsOfService: '#number', rate: '#number', amount: '#number', status: '#string', requestChangeId: '##number', remark: '##string', createdBy: '#number', confirmedBy: '##number', updatedBy: '##number', createdAt: '#string', updatedAt: '##string' }
    * match each response.data == itemSchema

  @smoke
  Scenario: List - filter by employeeId returns only that employee records
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-09-01', terminationType: 'OTHER', baseSalary: 1000.0, yearsOfService: 2.0, rate: 5.0, remark: 'List - filter by employeeId returns only that employee records' }
    When method POST
    Then status 201

    Given path '/api/v1/payment/severance-pays'
    And param employeeId = empId
    When method GET
    Then status 200
    * assert response.data.length > 0
    * karate.forEach(response.data, function(r){ karate.match(r.employeeId, empId) })

  @smoke
  Scenario: List - filter by status returns only matching records
    Given path '/api/v1/payment/severance-pays'
    And param status = 'PENDING'
    When method GET
    Then status 200
    And match response.data == '#array'
    * karate.forEach(response.data, function(r){ karate.match(r.status, 'PENDING') })
