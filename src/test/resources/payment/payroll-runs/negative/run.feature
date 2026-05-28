@payment @payroll_runs @negative
Feature: PAY-RUN-006 Payroll Run - Create Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Invalid period format - returns 400
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-13', scope: 'COMPANY' }
    When method POST
    Then status 400
    And match response.error contains 'period'
    And match response.data == null

  @negative
  Scenario: LOCATION scope without siteId - returns 400
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-11', scope: 'LOCATION' }
    When method POST
    Then status 400
    And match response.error contains 'siteId'
    And match response.data == null

  @negative
  Scenario: BUSINESS_UNIT scope without businessUnitId - returns 400
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-11', scope: 'BUSINESS_UNIT' }
    When method POST
    Then status 400
    And match response.error contains 'businessUnitId'
    And match response.data == null

  @negative
  Scenario: Duplicate non-cancelled run for same period and scope - returns 400
    # Create a DRAFT run first
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-09', scope: 'COMPANY' }
    When method POST
    Then status 200
    * def firstRunId = response.data.run.id
    # Attempt duplicate
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '2099-09', scope: 'COMPANY' }
    When method POST
    Then status 400
    And match response.error contains 'already exists'
    And match response.data == null
    # Cleanup
    Given path '/api/v1/payment/payroll-runs/' + firstRunId + '/cancel'
    And header X-User-Id = userId
    When method POST
    Then status 200
