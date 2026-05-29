@ignore
Feature: Helper - create a reminder rule and return its id

  Scenario:
    Given url notificationUrl
    And path '/api/v1/notification/reminder-rules'
    And header X-User-Id = userId
    And request __arg
    When method POST
    Then status 201
    * def createdId = response.data.id
