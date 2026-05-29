@notification @scheduler @positive
Feature: NT-SCH-002 Two ticks in the same day fire only once

  Background:
    * url notificationUrl
    * def today = java.time.LocalDate.now().toString()
    * def in3   = java.time.LocalDate.now().plusDays(3).toString()
    * def uniqueName = 'QA-Idem-' + java.lang.System.currentTimeMillis()
    * def created  = call read('classpath:notification/reminder-rules/helper/create-rule.feature') { name: '#(uniqueName)', dateKind: 'QA_IDEMPOTENT', offsetDays: [3], eventId: 1, channelIds: [2], isActive: true }
    * def upserted = call read('classpath:notification/scheduler/helper/upsert-date.feature') { employeeId: 10, employeeName: 'QA Idem', dateKind: 'QA_IDEMPOTENT', targetDate: '#(in3)' }

  @smoke
  Scenario: Second tick is a no-op
    * def first  = call read('classpath:notification/scheduler/helper/manual-tick.feature') { asOfDate: '#(today)' }
    * def second = call read('classpath:notification/scheduler/helper/manual-tick.feature') { asOfDate: '#(today)' }
    * assert first.summary.sent  >= 1
    * assert second.summary.sent == 0
