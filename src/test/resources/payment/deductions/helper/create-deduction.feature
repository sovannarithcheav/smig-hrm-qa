@ignore
Feature: Helper - create a deduction and return its id

  Scenario:
    Given url paymentUrl
    And path '/api/v1/payment/deductions'
    And header X-User-Id = userId
    And request __arg
    When method POST
    Then status 201
    * def createdId = response.data.id
