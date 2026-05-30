@ignore
Feature: Helper - create an allowance and return its id

  Scenario:
    Given url paymentUrl
    And path '/api/v1/payment/allowances'
    And header X-User-Id = userId
    And request __arg
    When method POST
    Then status 201
    * def createdId = response.data.id
