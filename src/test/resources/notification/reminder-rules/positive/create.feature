@notification @reminder-rules @positive
Feature: NT-RR-002 Create Reminder Rule

  Background:
    * url notificationUrl
    * def uniqueName = 'QA-Rule-' + java.lang.System.currentTimeMillis()

  @smoke
  Scenario: Happy path - returns 201 and the created rule
    Given path '/api/v1/notification/reminder-rules'
    And header X-User-Id = userId
    And request
      """
      {
        name: '#(uniqueName)',
        dateKind: 'PROBATION_END',
        offsetDays: [14, 7, 0],
        eventId: 1,
        channelIds: [2],
        isActive: true
      }
      """
    When method POST
    Then status 201
    And match response.data.id == '#number'
    And match response.data.name == uniqueName
    And match response.data.offsetDays == [14, 7, 0]
    And match response.data.isActive == true
