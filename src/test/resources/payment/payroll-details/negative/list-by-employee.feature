@payment @payroll_details @negative
Feature: PAY-DET-N-001 Payroll Details - missing employeeId returns 400

  Background:
    * url paymentUrl

  Scenario: Missing employeeId query param returns 400
    Given path '/api/v1/payment/payroll-details'
    When method GET
    Then status 400
    And match response.error contains 'employeeId'
