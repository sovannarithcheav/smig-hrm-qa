@ignore
Feature: Fetch a notification template by id

  Scenario:
    Given url notificationUrl
    And path '/api/v1/notification/templates/' + templateId
    When method GET
    Then status 200
    * def template = response.data
