@payment @nssf_reports @positive
Feature: PAY-NSSF-001 List NSSF Reports

  Background:
    * url paymentUrl

  @smoke
  Scenario: Happy path - returns array
    Given path '/api/v1/payment/nssf-reports'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: Filter by period returns matching summaries
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-11' })
    * def runId = res.runId
    Given path '/api/v1/payment/nssf-reports'
    And param period = '2099-11'
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match response.data[0].payrollRunId == '#number'
    And match response.data[0].period == '2099-11'
    And match response.data[0].totalNssfEmployee == '#number'
    And match response.data[0].totalNssfEmployer == '#number'
    And match response.data[0].totalNssf == '#number'
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
