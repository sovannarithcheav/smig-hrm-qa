@notification @scheduler @positive
Feature: NT-SCH-001 Scheduler tick fires a matching rule

  Background:
    * url notificationUrl
    * def today = java.time.LocalDate.now().toString()
    * def in7   = java.time.LocalDate.now().plusDays(7).toString()
    * def uniqueName = 'QA-Tick-' + java.lang.System.currentTimeMillis()
    * def created  = call read('classpath:notification/reminder-rules/helper/create-rule.feature') { name: '#(uniqueName)', dateKind: 'QA_PROBATION', offsetDays: [7], eventId: 1, channelIds: [2], isActive: true }
    * def ruleId   = created.createdId
    * def upserted = call read('classpath:notification/scheduler/helper/upsert-date.feature') { employeeId: 4242, employeeName: 'QA Test', dateKind: 'QA_PROBATION', targetDate: '#(in7)' }

  @smoke
  Scenario: Manual tick on today finds the in-7-days fact and fires once
    * def tick = call read('classpath:notification/scheduler/helper/manual-tick.feature') { asOfDate: '#(today)' }
    * assert tick.summary.matches >= 1
    * assert tick.summary.sent    >= 1
    * assert tick.summary.errors  == 0
