@payment @payslip_distributions @negative
Feature: PAY-DIST-N-001 Send Payslip Distribution - validation failures

  Background:
    * url paymentUrl

  Scenario: Non-existent batchId returns 404
    Given path '/api/v1/payment/payslip-distributions/send'
    And header X-User-Id = userId
    And request { batchId: 999999 }
    When method POST
    Then status 404

  Scenario: Missing batchId returns 400
    Given path '/api/v1/payment/payslip-distributions/send'
    And header X-User-Id = userId
    And request {}
    When method POST
    Then status 400
