@payment @severance_pays @negative @create
Feature: PAY-004 Severance Pay - Create Negative

  Background:
    * url paymentUrl
    * def empId = Math.floor(Math.random() * 50) + 1

  @negative
  Scenario: baseSalary zero - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'baseSalary'
    And match response.data == null

  @negative
  Scenario: baseSalary negative - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: -500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'baseSalary'
    And match response.data == null

  @negative
  Scenario: yearsOfService zero - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'yearsOfService'
    And match response.data == null

  @negative
  Scenario: rate zero - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 0 }
    When method POST
    Then status 400
    And match response.error contains 'rate'
    And match response.data == null

  @negative
  Scenario: Unknown terminationType - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'FIRED', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'termination type'
    And match response.data == null

  @negative
  Scenario: Invalid terminationDate format - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '01-06-2026', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'terminationDate'
    And match response.data == null

  @negative
  Scenario: Non-existent employeeId - returns 404
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: 999999999, terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: employeeId missing - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400

  @negative
  Scenario: employeeId zero - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: 0, terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'employeeId'
    And match response.data == null

  @negative
  Scenario: employeeId negative - returns 400
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: -1, terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'employeeId'
    And match response.data == null

  @negative
  Scenario: Duplicate PENDING record for same employee - returns 400
    * def uniqueEmpId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: uniqueEmpId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(uniqueEmpId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 2.0, rate: 7.5, remark: 'Duplicate PENDING record for same employee - returns 400' }
    When method POST
    Then status 201

    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(uniqueEmpId), terminationDate: '2026-07-01', terminationType: 'RESIGNATION', baseSalary: 1600.0, yearsOfService: 3.0, rate: 7.5 }
    When method POST
    Then status 400
    And match response.error contains 'pending'
    And match response.data == null
