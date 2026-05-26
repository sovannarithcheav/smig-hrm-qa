@notification @templates @positive
Feature: NT-003 Update Notification Template

  Background:
    # Capture original template state once before any scenario modifies it
    * def originalSetup = callonce read('classpath:notification/helper/fetch-template.feature') { templateId: 1 }
    * def original = originalSetup.template

    # Fetch all variables from DB once — used in scenarios that need a real variable id + label
    * def varSetup = callonce read('classpath:notification/helper/fetch-variables.feature') {}
    * def allVars  = varSetup.variables
    * def testVar  = allVars[0]

    # Cancel own pending notification-template request changes before each scenario
    Given url changeManagementUrl
    And path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    And params { subject: 'notification-template', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def myPendingIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(myPendingIds, function(id){ karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id }) })
    * url notificationUrl

  @smoke
  Scenario: Update body only — change is reflected in template after approval
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "Updated body for testing.", "statusId": 1 }
    When method PUT
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    And match response.error == null

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == 'Updated body for testing.'

  @smoke
  Scenario: Update with subject — change is reflected in template after approval
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "subject": "Test Subject", "body": "Updated with subject.", "statusId": 1, "variables": [] }
    When method PUT
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    And match response.error == null

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == 'Updated with subject.'
    And match response.data.subject == 'Test Subject'

  @smoke
  Scenario: Update with variables and matching placeholder — reflected after approval
    * def testBody = 'Dear ' + testVar.name + ', your request has been processed.'
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request
      """
      {
        "body": "#(testBody)",
        "statusId": 1,
        "variables": [{ "id": #(testVar.id) }]
      }
      """
    When method PUT
    Then status 202
    And match response.error == null
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
    And match response.error == null

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == testBody
    And match response.data.variables[0].id == testVar.id
