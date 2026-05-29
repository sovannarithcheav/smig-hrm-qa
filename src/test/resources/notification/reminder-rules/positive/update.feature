@notification @reminder-rules @positive
Feature: NT-RR-003 Update Reminder Rule

  Background:
    * url notificationUrl
    * def created = call read('classpath:notification/reminder-rules/helper/create-rule.feature') { name: 'QA-Rule-Upd', dateKind: 'PROBATION_END', offsetDays: [14], eventId: 1, channelIds: [2], isActive: true }
    * def ruleId = created.createdId

  @smoke
  Scenario: Update mutable fields
    Given path '/api/v1/notification/reminder-rules/' + ruleId
    And header X-User-Id = userId
    And request
      """
      {
        name: 'QA-Rule-Upd-renamed',
        dateKind: 'PROBATION_END',
        offsetDays: [14, 1],
        eventId: 1,
        channelIds: [2],
        isActive: false
      }
      """
    When method PUT
    Then status 200
    And match response.data.name == 'QA-Rule-Upd-renamed'
    And match response.data.offsetDays == [14, 1]
    And match response.data.isActive == false
