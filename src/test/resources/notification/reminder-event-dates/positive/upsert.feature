@notification @reminder_event_dates @positive
Feature: NT-RED-001 Upsert Reminder Event Date

  Background:
    * url notificationUrl

  @smoke
  Scenario: Upsert creates a new event date
    Given path '/api/v1/notification/reminder-event-dates'
    And request { employeeId: 9001, employeeName: 'QA Employee', dateKind: 'BIRTHDAY', targetDate: '1990-06-15', metadata: null }
    When method PUT
    Then status 200
    And match response.error == null
    And match response.data.employeeId == 9001
    And match response.data.dateKind == 'BIRTHDAY'
    And match response.data.targetDate == '1990-06-15'

  @smoke
  Scenario: Upsert same key updates the existing record
    Given path '/api/v1/notification/reminder-event-dates'
    And request { employeeId: 9001, employeeName: 'QA Employee', dateKind: 'BIRTHDAY', targetDate: '1991-07-20', metadata: null }
    When method PUT
    Then status 200
    And match response.data.targetDate == '1991-07-20'
