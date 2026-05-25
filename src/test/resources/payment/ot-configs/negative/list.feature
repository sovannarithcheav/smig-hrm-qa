@payment
Feature: PAY-001 List OT Configs - Negative

  Background:
    * url paymentUrl

  @negative
  Scenario: Update with non-existent id - returns 404
    Given path '/api/v1/payment/payroll-ot-config/999999'
    And request { multiplier: 2.0 }
    When method PUT
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Update with non-numeric id - returns 400
    Given path '/api/v1/payment/payroll-ot-config/abc'
    And request { multiplier: 2.0 }
    When method PUT
    Then status 400
    And match response.error != null
    And match response.data == null
