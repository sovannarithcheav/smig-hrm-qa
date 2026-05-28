@payment @payroll_runs @negative
Feature: PAY-RUN-007 Payroll Run - Submit Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Submit a CANCELLED run - returns 400
    # Create then immediately cancel
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-07', scope: 'COMPANY' }
    When method POST
    Then status 200
    * def runId = response.data.run.id
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
    # Now try to submit the cancelled run
    Given path '/api/v1/payment/payroll-runs/' + runId + '/submit'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error contains 'DRAFT'
    And match response.data == null

  @negative
  Scenario: Submit non-existent run - returns 400
    Given path '/api/v1/payment/payroll-runs/999999999/submit'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error != null
    And match response.data == null
