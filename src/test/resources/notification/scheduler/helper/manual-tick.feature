@ignore
Feature: Helper - fire the scheduler manually

  Scenario:
    Given url notificationUrl
    And path '/internal/scheduler/tick'
    And request { asOfDate: '#(asOfDate)' }
    When method POST
    Then status 200
    * def summary = response.data
