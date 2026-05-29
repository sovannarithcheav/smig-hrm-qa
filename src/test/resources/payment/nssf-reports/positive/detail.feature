@payment @nssf_reports @positive
Feature: PAY-NSSF-002 NSSF Report Detail

  Background:
    * url paymentUrl
    * def setup = callonce read('classpath:payment/payroll-runs/helper/create-run.feature') { period: '2099-12' }
    * def runId = setup.runId

  @smoke
  Scenario: Detail returns report with correct envelope
    Given path '/api/v1/payment/nssf-reports/' + runId
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.payrollRunId == runId
    And match response.data.period == '2099-12'
    And match response.data.rows == '#array'
    And match response.data.totalNssfEmployee == '#number'
    And match response.data.totalNssfEmployer == '#number'
    And match response.data.totalNssf == '#number'

  @smoke
  Scenario: Each row has required NSSF fields and rate check
    Given path '/api/v1/payment/nssf-reports/' + runId
    When method GET
    Then status 200
    * def rows = response.data.rows
    * if (rows.length > 0) karate.match(rows[0], { employeeId: '#number', employeeName: '#string', position: '#string', nssfBase: '#number', nssfEmployee: '#number', nssfEmployer: '#number', nssfTotal: '#number' })
    * def rateOk = rows.length == 0 || Math.abs(rows[0].nssfEmployee - rows[0].nssfBase * 0.02) < 0.01
    * assert rateOk

  @smoke
  Scenario: totalNssf equals totalNssfEmployee + totalNssfEmployer
    Given path '/api/v1/payment/nssf-reports/' + runId
    When method GET
    Then status 200
    * def d = response.data
    * assert Math.abs(d.totalNssf - (d.totalNssfEmployee + d.totalNssfEmployer)) < 0.01

  Scenario: Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
