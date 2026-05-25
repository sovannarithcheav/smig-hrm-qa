@notification
Feature: NT-E2E Send Notification Flow - Negative

  Background:
    * url notificationUrl
    * def targetUserId = 10

  @e2e @negative
  Scenario: Send with unknown eventCode - returns 422 with failure message
    Given path '/api/v1/notification/send'
    And header X-User-Id = userId
    And request { userId: #(targetUserId), eventCode: 'UNKNOWN_EVENT', mergeFields: {} }
    When method POST
    Then status 422
    And match response.error == null
    And match response.data[0].success == false
    And match response.data[0].message contains 'not found'

  @e2e @negative
  Scenario: Send with non-existent userId - returns subscription error
    Given path '/api/v1/notification/send'
    And header X-User-Id = userId
    And request { userId: 999999, eventCode: 'PWD_RESET_SUCC', mergeFields: {} }
    When method POST
    Then status 500
