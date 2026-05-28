@payment @payroll_runs @negative
Feature: PAY-RUN-008 Payroll Run - Cancel Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Cancel an already-CANCELLED run - returns 400
    # Create run
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-06', scope: 'COMPANY' }
    When method POST
    Then status 200
    * def runId = response.data.run.id
    # First cancel succeeds
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
    And match response.data.status == 'CANCELLED'
    # Second cancel fails
    Given path '/api/v1/payment/payroll-runs/' + runId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error contains 'DRAFT'
    And match response.data == null

  @negative
  Scenario: Cancel non-existent run - returns 400
    Given path '/api/v1/payment/payroll-runs/999999999/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error != null
    And match response.data == null
