@payment @payroll_runs @positive @smoke
Feature: PAY-RUN-004 Payroll Run - Cancel

  Background:
    * url paymentUrl

  @smoke
  Scenario: Cancel a DRAFT run - returns 200 with CANCELLED status
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-04' })
    * def runId = res.runId
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
    And match response.error == null
    And match response.data.id == runId
    And match response.data.status == 'CANCELLED'
