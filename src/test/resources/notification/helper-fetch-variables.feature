@ignore
Feature: Fetch all notification variables

  Scenario:
    Given url notificationUrl
    And path '/api/v1/notification/variables'
    When method GET
    Then status 200
    And match response.data == '#[] #notnull'
    * def variables = response.data
