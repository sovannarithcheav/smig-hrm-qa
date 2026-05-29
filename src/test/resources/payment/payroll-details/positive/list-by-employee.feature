@payment @payroll_details @positive
Feature: PAY-DET-001 Payroll Details - List by Employee (ESS)

  Background:
    * url paymentUrl
    * def setup = callonce read('classpath:payment/payroll-runs/helper/create-run.feature') { period: '2099-05' }
    * def runId = setup.runId

  @smoke
  Scenario: Returns array of pay details for a seeded employee
    # Employee 1 is always seeded; run created above generates their detail
    Given path '/api/v1/payment/payroll-details'
    And param employeeId = 1
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'
    And match response.data == '#[_ > 0]'
    And match each response.data contains { employeeId: 1 }

  @smoke
  Scenario: Each item has expected payroll detail fields
    Given path '/api/v1/payment/payroll-details'
    And param employeeId = 1
    When method GET
    Then status 200
    * def item = response.data[0]
    And match item.id == '#number'
    And match item.payrollBatchId == '#number'
    And match item.employeeId == 1
    And match item.basicSalary == '#number'
    And match item.grossPay == '#number'
    And match item.netPay == '#number'
    And match item.status == '#string'

  @smoke
  Scenario: Pagination - page and size are respected
    Given path '/api/v1/payment/payroll-details'
    And param employeeId = 1
    And param page = 0
    And param size = 2
    When method GET
    Then status 200
    And match response.data == '#[_ <= 2]'

  @smoke
  Scenario: Unknown employee returns empty array
    Given path '/api/v1/payment/payroll-details'
    And param employeeId = 999999
    When method GET
    Then status 200
    And match response.data == '#[0]'

  Scenario: Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
