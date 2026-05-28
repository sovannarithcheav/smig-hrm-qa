@payment @payroll_runs @positive @e2e
Feature: PAY-RUN-005 Payroll Run - Full Lifecycle (Run → Submit → Approve)

  Background:
    * url paymentUrl
    * def year = '' + (new Date().getFullYear() + 100)
    * def month = ('0' + (new Date().getMonth() + 1)).slice(-2)
    * def period = year + '-' + month

  @e2e
  Scenario: Run payroll → submit → approve via CS → run becomes APPROVED
    * print '=== STEP 1: Create COMPANY scope payroll run ==='
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '#(period)', scope: 'COMPANY' }
    When method POST
    Then status 200
    And match response.data.run.status == 'DRAFT'
    And match response.data.run.totalEmployees == '#number? _ > 0'
    * def runId = response.data.run.id

    * print '=== STEP 2: Submit run for approval ==='
    Given path '/api/v1/payment/payroll-runs/' + runId + '/submit'
    And header X-User-Id = userId
    When method POST
    Then status 202
    And match response.data.status == 'IN_REVIEW'
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    * print '=== STEP 3: Approve via Change Management Service ==='
    * url changeManagementUrl
    Given path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    * karate.pause(1000)

    * print '=== STEP 4: Verify run is APPROVED ==='
    * url paymentUrl
    Given path '/api/v1/payment/payroll-runs/' + runId
    When method GET
    Then status 200
    And match response.data.run.status == 'APPROVED'
    And match response.data.run.approvedBy == '#number'
