@notification @event_notifications @negative
Feature: NT-EN-N-001 Event Notification — not found

  Background:
    * url notificationUrl

  Scenario: Unknown ID returns 404
    Given path '/api/v1/notification/event-notifications/999999'
    When method GET
    Then status 404
