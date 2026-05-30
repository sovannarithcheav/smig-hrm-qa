@notification @event_notifications @negative
Feature: NT-EN-N-002 Create Event Notification — validation errors

  Background:
    * url notificationUrl

  Scenario: Missing required code field returns 400
    Given path '/api/v1/notification/event-notifications'
    And header X-User-Id = userId
    And request { name: 'No Code Event', type: 'All', statusId: 1, categoryId: 1 }
    When method POST
    Then status 400
    And match response != null
