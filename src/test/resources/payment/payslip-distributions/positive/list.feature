@payment @payslip_distributions @positive
Feature: PAY-DIST-001 List Payslip Distributions

  Background:
    * url paymentUrl

  @smoke
  Scenario: Happy path - returns array
    Given path '/api/v1/payment/payslip-distributions'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#array'

  @smoke
  Scenario: DRAFT batch is not in distribution list
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-06' })
    * def runId = res.runId
    Given path '/api/v1/payment/payslip-distributions'
    And param period = '2099-06'
    When method GET
    Then status 200
    And match response.data == '#[0]'
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
