@notification @event_notifications @positive
Feature: NT-EN-004 Update Event Notification

  Background:
    * url notificationUrl
    * def uniqueCode = 'TEST_UPDATE_' + java.lang.System.currentTimeMillis()

  @smoke
  Scenario: Update name and description - change is persisted and then restored
    # Create a throwaway event
    Given path '/api/v1/notification/event-notifications'
    And header X-User-Id = userId
    And request { code: '#(uniqueCode)', name: 'Before Update', description: 'Original', type: 'All', isRequired: false, statusId: 1, categoryId: 1 }
    When method POST
    Then status 201
    * def id = response.data.id

    # Update it
    Given path '/api/v1/notification/event-notifications/' + id
    And header X-User-Id = userId
    And request { code: '#(uniqueCode)', name: 'After Update', description: 'Updated by Karate', type: 'All', isRequired: false, statusId: 1, categoryId: 1 }
    When method PUT
    Then status 200
    And match response.data.name == 'After Update'
    And match response.data.description == 'Updated by Karate'

    # Restore original state
    Given path '/api/v1/notification/event-notifications/' + id
    And header X-User-Id = userId
    And request { code: '#(uniqueCode)', name: 'Before Update', description: 'Original', type: 'All', isRequired: false, statusId: 1, categoryId: 1 }
    When method PUT
    Then status 200
    And match response.data.name == 'Before Update'
