@notification @event_notifications @positive
Feature: NT-EN-003 Create Event Notification

  Background:
    * url notificationUrl
    # Unique code per run — no DELETE endpoint, so avoid code conflicts on re-run
    * def uniqueCode = 'TEST_EVENT_' + java.lang.System.currentTimeMillis()

  @smoke
  Scenario: Create new event returns 201 with correct shape
    Given path '/api/v1/notification/event-notifications'
    And header X-User-Id = userId
    And request { code: '#(uniqueCode)', name: 'QA Test Event', description: 'Created by Karate QA', type: 'All', isRequired: false, statusId: 1, categoryId: 1 }
    When method POST
    Then status 201
    And match response.error == null
    And match response.data.id == '#number'
    And match response.data.code == uniqueCode
    And match response.data.name == 'QA Test Event'
