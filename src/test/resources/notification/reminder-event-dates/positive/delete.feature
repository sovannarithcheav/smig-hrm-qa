@notification @reminder_event_dates @positive
Feature: NT-RED-002 Delete Reminder Event Date

  Background:
    * url notificationUrl

  @smoke
  Scenario: Delete existing event date returns 204
    Given path '/api/v1/notification/reminder-event-dates'
    And request { employeeId: 9002, employeeName: 'QA Delete Employee', dateKind: 'BIRTHDAY', targetDate: '1985-03-10', metadata: null }
    When method PUT
    Then status 200

    Given path '/api/v1/notification/reminder-event-dates/9002/BIRTHDAY'
    When method DELETE
    Then status 204
