@payment @severance_pays @positive @create
Feature: PAY-004 Severance Pay - Create

  Background:
    * url paymentUrl
    * def uniqueEmployeeId = Math.floor(Math.random() * 50) + 1
    * def validBody =
      """
      {
        "employeeId": #(uniqueEmployeeId),
        "terminationDate": "2026-06-01",
        "terminationType": "RESIGNATION",
        "baseSalary": 1500.00,
        "yearsOfService": 3.5,
        "rate": 7.5,
        "remark": "Create severance pay - returns 201 with PENDING status and correct schema"
      }
      """

  @smoke
  Scenario: Create severance pay - returns 201 with PENDING status and correct schema
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: uniqueEmployeeId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.employeeId == uniqueEmployeeId
    And match response.data.terminationDate == '2026-06-01'
    And match response.data.terminationType == 'RESIGNATION'
    And match response.data.baseSalary == 1500.0
    And match response.data.yearsOfService == 3.5
    And match response.data.rate == 7.5
    And match response.data.amount == '#number'
    And match response.data.status == 'PENDING'
    And match response.data.requestChangeId == '#number'
    And match response.data.remark == 'Create severance pay - returns 201 with PENDING status and correct schema'
    And match response.data.createdBy == '#number'
    And match response.data.createdAt == '#string'
    And match response.data.updatedAt == '##string'
    * def createdId = response.data.id
    Given path '/api/v1/payment/severance-pays/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202

  @smoke
  Scenario: Create with TERMINATION type - succeeds with 201
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-07-01', terminationType: 'TERMINATION', baseSalary: 2000.0, yearsOfService: 5.0, rate: 8.0, remark: 'Create with TERMINATION type - succeeds with 201' }
    When method POST
    Then status 201
    And match response.data.terminationType == 'TERMINATION'
    And match response.data.status == 'PENDING'
    * def createdId = response.data.id
    Given path '/api/v1/payment/severance-pays/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202

  @smoke
  Scenario: Create with RETIREMENT type - succeeds with 201
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-08-01', terminationType: 'RETIREMENT', baseSalary: 3000.0, yearsOfService: 10.0, rate: 10.0, remark: 'Create with RETIREMENT type - succeeds with 201' }
    When method POST
    Then status 201
    And match response.data.terminationType == 'RETIREMENT'
    * def createdId = response.data.id
    Given path '/api/v1/payment/severance-pays/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202

  @smoke
  Scenario: Amount is computed as baseSalary x yearsOfService x rate / 100
    * def empId = Math.floor(Math.random() * 50) + 1
    * def pending = karate.call('classpath:payment/severance-pays/helper/list-pending-ids.feature', { empId: empId }).ids
    * call read('classpath:payment/severance-pays/helper/do-cancel.feature') pending
    Given path '/api/v1/payment/severance-pays'
    And header X-User-Id = userId
    And request { employeeId: #(empId), terminationDate: '2026-06-01', terminationType: 'RESIGNATION', baseSalary: 1500.0, yearsOfService: 3.5, rate: 7.5, remark: 'Amount is computed as baseSalary x yearsOfService x rate / 100' }
    When method POST
    Then status 201
    # 1500.00 * 3.5 * 7.5 / 100 = 393.75
    And match response.data.amount == 393.75
    * def createdId = response.data.id
    Given path '/api/v1/payment/severance-pays/' + createdId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 202
