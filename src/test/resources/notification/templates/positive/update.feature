@notification @templates @positive
Feature: NT-003 Update Notification Template

  Background:
    # Capture original template state once before any scenario modifies it
    * def originalSetup = callonce read('classpath:notification/helper/fetch-template.feature') { templateId: 1 }
    * def original = originalSetup.template

    # Fetch all variables from DB once
    * def varSetup = callonce read('classpath:notification/helper/fetch-variables.feature') {}
    * def allVars  = varSetup.variables

    # Compute original variable IDs from body placeholders (avoids stale original.variables)
    * def extractPlaceholders = function(text){ return (text || '').match(/\$\{[^}]+\}/g) || [] }
    * def allBodyPlaceholders = extractPlaceholders(original.body).concat(extractPlaceholders(original.subject))
    * def uniquePlaceholders = allBodyPlaceholders.filter(function(v,i,a){ return a.indexOf(v) === i })
    * def varsMap = {}
    * karate.forEach(allVars, function(v){ varsMap[v.name] = v.id })
    * def originalVarIds = uniquePlaceholders.map(function(p){ return { id: varsMap[p] } }).filter(function(x){ return x.id !== undefined })

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

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "subject": "#(original.subject)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == original.body

  @smoke
  Scenario: Update with subject — change is reflected in template after approval
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "Updated with subject.", "subject": "Test Subject", "statusId": 1 }
    When method PUT
    Then status 202
    And match response.error == null
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == 'Updated with subject.'
    And match response.data.subject == 'Test Subject'

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "subject": "#(original.subject)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

  @smoke
  Scenario: Update with variables and matching placeholder — reflected after approval
    * def testVar = allVars[0]
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
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == testBody
    And match response.data.variables[0].id == testVar.id

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "subject": "#(original.subject)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

  Scenario: Update multiple variables with all matching placeholders — all reflected after approval
    * def var1 = allVars[0]
    * def var2 = allVars[1]
    * def var3 = allVars[2]
    * def multiBody = 'Hello ' + var1.name + ', period is ' + var2.name + ', net pay is ' + var3.name + '.'
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request
      """
      {
        "body": "#(multiBody)",
        "statusId": 1,
        "variables": [{ "id": #(var1.id) }, { "id": #(var2.id) }, { "id": #(var3.id) }]
      }
      """
    When method PUT
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == multiBody
    * assert response.data.variables.length == 3

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "subject": "#(original.subject)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

  Scenario: Update statusId to inactive — status change reflected after approval
    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "statusId": 2, "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.status.id == 2

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "subject": "#(original.subject)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

  Scenario: Update with empty variables and body with no placeholders — accepted without mismatch
    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "Plain text without any placeholders.", "statusId": 1, "variables": [] }
    When method PUT
    Then status 202
    And match response.error == null
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == 'Plain text without any placeholders.'

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "subject": "#(original.subject)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

  Scenario: Update with X-User-Id header — updatedBy is recorded after approval
    * def userIdNum = parseInt(userId)
    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(original.body)", "statusId": #(original.status.id), "variables": #(originalVarIds) }
    When method PUT
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.updatedBy == userIdNum

  Scenario: Reject request change — template body remains unchanged
    * def bodyBefore = original.body
    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "This change will be rejected.", "statusId": 1 }
    When method PUT
    Then status 202
    * def requestChangeId = response.data.requestChangeId

    Given url changeManagementUrl
    And path '/api/v1/request-change/' + requestChangeId + '/reject'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    And header Content-Type = 'application/json'
    And request {}
    When method POST
    Then status 200
    And match response.error == null

    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.data.body == bodyBefore
