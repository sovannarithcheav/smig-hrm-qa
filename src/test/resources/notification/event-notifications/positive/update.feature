@notification @event_notifications @positive
Feature: NT-EN-004 Update Event Notification

  Background:
    * url notificationUrl

  @smoke
  Scenario: Update name and description - change is persisted
    Given path '/api/v1/notification/event-notifications'
    And header X-User-Id = userId
    And request { code: 'TEST_UPDATE_QA', name: 'Before Update', description: 'Original', type: 'All', isRequired: false, statusId: 1, categoryId: 1 }
    When method POST
    Then status 201
    * def id = response.data.id

    Given path '/api/v1/notification/event-notifications/' + id
    And header X-User-Id = userId
    And request { code: 'TEST_UPDATE_QA', name: 'After Update', description: 'Updated by Karate', type: 'All', isRequired: false, statusId: 1, categoryId: 1 }
    When method PUT
    Then status 200
    And match response.data.name == 'After Update'
    And match response.data.description == 'Updated by Karate'
