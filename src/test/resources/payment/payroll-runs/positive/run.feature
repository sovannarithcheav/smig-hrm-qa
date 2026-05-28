@payment @payroll_runs @positive @create @smoke
Feature: PAY-RUN-001 Payroll Run - Create

  Background:
    * url paymentUrl

  @smoke
  Scenario: Create COMPANY scope run - returns 200 with DRAFT status and populated totals
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-01', scope: 'COMPANY' }
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.run.id == '#number'
    And match response.data.run.period == '2099-01'
    And match response.data.run.scope == 'COMPANY'
    And match response.data.run.status == 'DRAFT'
    And match response.data.run.totalBatches == '#number'
    And match response.data.run.totalEmployees == '#number'
    And match response.data.run.totalGross == '#number'
    And match response.data.run.totalNet == '#number'
    And match response.data.run.createdBy == '#number'
    And match response.data.run.requestChangeId == '##number'
    And match response.data.batches == '#[]'
    * def runId = response.data.run.id
    # Cleanup — cancel so this period can be reused
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
