@payment @seniority_pays @negative @create
Feature: PAY-SEN-N-001 Seniority Pay - Create Negative

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  Scenario: Non-existent employeeId - returns 400
    Given path '/api/v1/payment/seniority-pays'
    And header X-User-Id = userId
    And request { employeeId: 999999, yearsOfService: 5.0, baseSalary: 1500.0, rate: 0.02, paymentPeriod: '2026-06' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Invalid paymentPeriod format - returns 400
    Given path '/api/v1/payment/seniority-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), yearsOfService: 5.0, baseSalary: 1500.0, rate: 0.02, paymentPeriod: '2026/06' }
    When method POST
    Then status 400
    And match response.data == null

  Scenario: Cancel non-existent id - returns 400
    Given path '/api/v1/payment/seniority-pays/999999/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.data == null
