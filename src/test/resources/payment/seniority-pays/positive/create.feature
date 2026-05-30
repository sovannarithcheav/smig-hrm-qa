@payment @seniority_pays @positive @create
Feature: PAY-SEN-001 Seniority Pay - Create

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @smoke
  Scenario: Create seniority pay - returns 201 with PENDING status
    Given path '/api/v1/payment/seniority-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), yearsOfService: 5.0, baseSalary: 1500.00, rate: 0.02, paymentPeriod: '2026-06', remark: 'Seniority pay 2026' }
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == empId
    And match response.data.yearsOfService == 5.0
    And match response.data.baseSalary == 1500.0
    And match response.data.rate == 0.02
    And match response.data.paymentPeriod == '2026-06'
    And match response.data.amount == '#number'
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    * def createdId = response.data.id
    # Cleanup
    Given path '/api/v1/payment/seniority-pays/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202

  @smoke
  Scenario: List seniority pays - returns array
    Given path '/api/v1/payment/seniority-pays'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Get by id - returns correct record
    * def created = call read('classpath:payment/seniority-pays/helper/create-seniority.feature') { employeeId: #(empId), yearsOfService: 3.0, baseSalary: 1200.0, rate: 0.02, paymentPeriod: '2026-06' }
    Given path '/api/v1/payment/seniority-pays/' + created.createdId
    When method GET
    Then status 200
    And match response.data.id == created.createdId
    And match response.data.yearsOfService == 3.0
    # Cleanup
    Given path '/api/v1/payment/seniority-pays/' + created.createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202
