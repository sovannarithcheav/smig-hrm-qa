@notification @reminder_event_dates @negative
Feature: NT-RED-N-001 Upsert Reminder Event Date — validation errors

  Background:
    * url notificationUrl

  Scenario: Missing employeeId returns 400
    Given path '/api/v1/notification/reminder-event-dates'
    And request { employeeName: 'No ID', dateKind: 'BIRTHDAY', targetDate: '1990-01-01' }
    When method PUT
    Then status 400
    And match response != null

  Scenario: Delete non-existent record returns 404
    Given path '/api/v1/notification/reminder-event-dates/999999/BIRTHDAY'
    When method DELETE
    Then status 404
