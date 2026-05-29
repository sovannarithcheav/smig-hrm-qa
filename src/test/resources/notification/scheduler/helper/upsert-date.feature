@ignore
Feature: Helper - upsert a reminder event date

  Scenario:
    Given url notificationUrl
    And path '/api/v1/notification/reminder-event-dates'
    And request __arg
    When method PUT
    Then status 200
    * def upserted = response.data
