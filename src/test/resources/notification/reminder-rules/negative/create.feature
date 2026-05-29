@notification @reminder-rules @negative
Feature: NT-RR-N-001 Create Reminder Rule - validation failures

  Background:
    * url notificationUrl

  Scenario: Empty offset_days returns 400
    Given path '/api/v1/notification/reminder-rules'
    And header X-User-Id = userId
    And request { name: 'bad', dateKind: 'X', offsetDays: [], eventId: 1, channelIds: [2] }
    When method POST
    Then status 400
    And match response.error contains 'offset_days'

  Scenario: Negative offset returns 400
    Given path '/api/v1/notification/reminder-rules'
    And header X-User-Id = userId
    And request { name: 'bad', dateKind: 'X', offsetDays: [-1], eventId: 1, channelIds: [2] }
    When method POST
    Then status 400
    And match response.error contains 'non-negative'

  Scenario: Unknown event_id returns 400
    Given path '/api/v1/notification/reminder-rules'
    And header X-User-Id = userId
    And request { name: 'bad', dateKind: 'X', offsetDays: [1], eventId: 999999, channelIds: [2] }
    When method POST
    Then status 400
    And match response.error contains 'not found'

  Scenario: Empty channel_ids returns 400
    Given path '/api/v1/notification/reminder-rules'
    And header X-User-Id = userId
    And request { name: 'bad', dateKind: 'X', offsetDays: [1], eventId: 1, channelIds: [] }
    When method POST
    Then status 400
    And match response.error contains 'channel_ids'

  Scenario: Update changes immutable date_kind returns 400
    * def created = call read('classpath:notification/reminder-rules/helper/create-rule.feature') { name: 'imm', dateKind: 'PROBATION_END', offsetDays: [1], eventId: 1, channelIds: [2], isActive: true }
    Given path '/api/v1/notification/reminder-rules/' + created.createdId
    And header X-User-Id = userId
    And request { name: 'imm', dateKind: 'CONTRACT_END', offsetDays: [1], eventId: 1, channelIds: [2], isActive: true }
    When method PUT
    Then status 400
    And match response.error contains 'immutable'
