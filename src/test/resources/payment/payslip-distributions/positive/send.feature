@payment @payslip_distributions @positive @e2e
Feature: PAY-DIST-002 Send Payslip Distribution

  Background:
    * url paymentUrl
    * def year = '' + (new Date().getFullYear() + 100)
    * def period = year + '-04'
    * def setup = callonce read('classpath:payment/payroll-runs/helper/create-run.feature') { period: '#(period)' }
    * def runId = setup.runId

  @smoke
  Scenario: DRAFT batch returns 400 - status guard
    * url paymentUrl
    Given path '/api/v1/payment/payroll-runs/' + runId
    When method GET
    Then status 200
    * def batchId = response.data.batches[0].id
    Given path '/api/v1/payment/payslip-distributions/send'
    And header X-User-Id = userId
    And request { batchId: #(batchId) }
    When method POST
    Then status 400
    And match response.error contains 'APPROVED or PAID'

  @e2e
  Scenario: APPROVED batch sends to all employees and returns correct counts
    * url paymentUrl
    # Submit the run
    Given path '/api/v1/payment/payroll-runs/' + runId + '/submit'
    And header X-User-Id = userId
    When method POST
    Then status 202
    * def requestChangeId = response.data.requestChangeId
    # Approve via CS
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    * karate.pause(1000)
    # Verify APPROVED, pick first batch
    * url paymentUrl
    Given path '/api/v1/payment/payroll-runs/' + runId
    When method GET
    Then status 200
    And match response.data.run.status == 'APPROVED'
    * def batchId    = response.data.batches[0].id
    * def batchEmpCount = response.data.batches[0].totalEmployees
    # Send pay slips
    Given path '/api/v1/payment/payslip-distributions/send'
    And header X-User-Id = userId
    And request { batchId: #(batchId) }
    When method POST
    Then status 200
    And match response.data.batchId == batchId
    And match response.data.sent == batchEmpCount
    And match response.data.skipped == 0
    # Verify batch appears in distribution list
    Given path '/api/v1/payment/payslip-distributions'
    And param period = period
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match response.data[0].status == '#regex APPROVED|PAID'
