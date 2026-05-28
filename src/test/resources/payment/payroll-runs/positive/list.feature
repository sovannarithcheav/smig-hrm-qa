@payment @payroll_runs @positive @smoke
Feature: PAY-RUN-002 Payroll Run - List

  Background:
    * url paymentUrl

  @smoke
  Scenario: List runs - returns 200 with array
    # Ensure at least one run exists
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-02' })
    * def runId = res.runId
    Given path '/api/v1/payment/payroll-runs'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data == '#[]'
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200

  @smoke
  Scenario: Filter by period returns matching runs
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-08' })
    * def runId = res.runId
    Given path '/api/v1/payment/payroll-runs'
    And param period = '2099-08'
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data == { id: '#number', period: '2099-08', scope: '#string', status: '#string', totalBatches: '#number', totalEmployees: '#number', totalGross: '#number', totalNet: '#number', totalNssfEmployer: '#number', createdBy: '#number', createdAt: '#string', approvedBy: '##number', approvedAt: '##string', updatedAt: '##string', requestChangeId: '##number', businessUnitId: '##number', siteId: '##number' }
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200

  @smoke
  Scenario: Filter by status=DRAFT returns only DRAFT runs
    * def res = karate.call('classpath:payment/payroll-runs/helper/create-run.feature', { period: '2099-10' })
    * def runId = res.runId
    Given path '/api/v1/payment/payroll-runs'
    And param status = 'DRAFT'
    When method GET
    Then status 200
    And match each response.data contains { status: 'DRAFT' }
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
