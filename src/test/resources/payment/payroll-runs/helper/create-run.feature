@ignore
Feature: Helper - Create payroll run

  Scenario: Create COMPANY scope payroll run
    Given url paymentUrl
    Given path '/api/v1/payment/payroll-runs'
    And header X-User-Id = userId
    And request { period: '#(period)', scope: 'COMPANY' }
    When method POST
    Then status 200
    * def runId = response.data.run.id
