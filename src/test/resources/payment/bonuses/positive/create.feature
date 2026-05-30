@payment @bonuses @positive @create
Feature: PAY-BONUS-001 Bonus - Create

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @smoke
  Scenario: Create bonus - returns 201 with PENDING status
    Given path '/api/v1/payment/bonuses'
    And header X-User-Id = userId
    And request { employeeId: #(empId), bonusType: 'PERFORMANCE', amount: 1000.00, taxable: false, paymentPeriod: '2026-06', remark: 'Q2 performance bonus' }
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == empId
    And match response.data.bonusType == 'PERFORMANCE'
    And match response.data.amount == 1000.0
    And match response.data.paymentPeriod == '2026-06'
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    * def createdId = response.data.id
    # Cleanup
    Given path '/api/v1/payment/bonuses/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202

  @smoke
  Scenario: List bonuses - returns array
    Given path '/api/v1/payment/bonuses'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Get by id - returns correct record
    * def created = call read('classpath:payment/bonuses/helper/create-bonus.feature') { employeeId: #(empId), bonusType: 'ANNUAL', amount: 500.0, taxable: false, paymentPeriod: '2026-06' }
    Given path '/api/v1/payment/bonuses/' + created.createdId
    When method GET
    Then status 200
    And match response.data.id == created.createdId
    And match response.data.bonusType == 'ANNUAL'
    # Cleanup
    Given path '/api/v1/payment/bonuses/' + created.createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202
