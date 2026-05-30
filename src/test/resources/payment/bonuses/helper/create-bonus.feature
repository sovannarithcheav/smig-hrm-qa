@ignore
Feature: Helper - create a bonus and return its id

  Scenario:
    Given url paymentUrl
    And path '/api/v1/payment/bonuses'
    And header X-User-Id = userId
    And request __arg
    When method POST
    Then status 201
    * def createdId = response.data.id
