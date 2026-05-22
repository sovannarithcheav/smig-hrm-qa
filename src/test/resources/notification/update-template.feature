@notification
Feature: NT-003 Update Notification Template

  Background:
    # Cancel own pending notification-template request changes so each scenario starts clean
    Given url changeManagementUrl
    And path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    And params { subject: 'notification-template', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def myPendingIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(myPendingIds, function(id){ karate.call('classpath:change-management/helper-cancel.feature', { cancelId: id }) })
    * url notificationUrl

  # ---------- Positive ----------

  @smoke
  Scenario: Happy path - returns 202 with requestChangeId
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "Hello, this is a test template body.", "statusId": 1 }
    When method PUT
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'

  @smoke
  Scenario: Update with optional subject and variables - returns 202
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "subject": "Test Subject", "body": "Hello, this is a test.", "statusId": 1, "variables": [] }
    When method PUT
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'

  # ---------- Negative ----------

  @negative
  Scenario: Non-numeric id - returns 400
    Given path '/api/v1/notification/templates/abc'
    And header X-User-Id = userId
    And request { "body": "Hello", "statusId": 1 }
    When method PUT
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Non-existent id - returns 404
    Given path '/api/v1/notification/templates/999999'
    And header X-User-Id = userId
    And request { "body": "Hello", "statusId": 1 }
    When method PUT
    Then status 404
    And match response.error != null
    And match response.data == null
