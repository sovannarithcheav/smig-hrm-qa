@ignore
Feature: Helper - create a loan and return its id

  Scenario:
    Given url paymentUrl
    And path '/api/v1/payment/loans'
    And header X-User-Id = userId
    And request __arg
    When method POST
    Then status 201
    * def createdId = response.data.id
