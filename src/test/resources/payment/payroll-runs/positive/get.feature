@payment @payroll_runs @positive @smoke
Feature: PAY-RUN-003 Payroll Run - Get By ID

  Background:
    * url paymentUrl

  @smoke
  Scenario: Get run by ID - returns 200 with run and batches
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-03' })
    * def runId = res.runId
    Given path '/api/v1/payment/payroll-runs/' + runId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.run.id == runId
    And match response.data.run.status == 'DRAFT'
    And match response.data.batches == '#[]'
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200

  @smoke
  Scenario: Get batch details - returns 200 with employee details
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-05' })
    * def runId = res.runId
    # Fetch run to get a batch id
    Given path '/api/v1/payment/payroll-runs/' + runId
    When method GET
    Then status 200
    * def batchId = response.data.batches[0].id
    # Fetch batch details
    Given path '/api/v1/payment/payroll-batches/' + batchId + '/details'
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data contains { id: '#number', employeeId: '#number', grossPay: '#number', netPay: '#number', status: 'PENDING' }
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
