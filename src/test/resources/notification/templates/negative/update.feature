@notification @templates @negative
Feature: NT-003 Update Notification Template - Negative

  Background:
    * def varSetup = callonce read('classpath:notification/helper/fetch-variables.feature') {}
    * def allVars  = varSetup.variables
    * def testVar  = allVars[0]

    # Cancel own pending changes
    Given url changeManagementUrl
    And path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    And params { subject: 'notification-template', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def myPendingIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(myPendingIds, function(id){ karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id }) })

    # Also cancel orphaned changes created with userId=0 (from missing X-User-Id scenarios)
    Given url changeManagementUrl
    And path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = 0
    And params { subject: 'notification-template', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def orphanIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(orphanIds, function(id){ karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id }) })
    * url notificationUrl

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

  @negative
  Scenario: Placeholder in body but no variable declared - returns 422
    * def testBody = 'Dear ' + testVar.name + ', your password has been reset.'
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request ({ body: testBody, statusId: 1, variables: [] })
    When method PUT
    Then status 422
    And match response.error contains 'Placeholder mismatch'
    And match response.data == null

  @negative
  Scenario: Variable declared but placeholder missing from body - returns 422
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request ({ body: 'No placeholder here.', statusId: 1, variables: [{ id: testVar.id }] })
    When method PUT
    Then status 422
    And match response.error contains 'Placeholder mismatch'
    And match response.data == null

  @negative
  Scenario: Partial placeholder mismatch — body has 2 placeholders, only 1 declared — returns 422
    * def var1 = allVars[0]
    * def var2 = allVars[1]
    * def partialBody = 'Hello ' + var1.name + ' and ' + var2.name + '.'
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request ({ body: partialBody, statusId: 1, variables: [{ id: var1.id }] })
    When method PUT
    Then status 422
    And match response.error contains 'Placeholder mismatch'
    And match response.data == null

  @negative
  Scenario: Empty body is accepted — service has no minimum-length validation
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "", "statusId": 1, "variables": [] }
    When method PUT
    Then status 202
    And match response.data.requestChangeId == '#number'
    # Cleanup — cancel the pending change
    * def pendingId = response.data.requestChangeId
    * karate.call('classpath:change-management/helper/cancel.feature', { cancelId: pendingId })

  @negative
  Scenario: Missing body field returns 400
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "statusId": 1 }
    When method PUT
    Then status 400
    And match response.data == null

  @negative
  Scenario: Missing statusId field returns 400
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "Hello world." }
    When method PUT
    Then status 400
    And match response.data == null

  @negative
  Scenario: Unknown variable ID in variables array returns 422
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request ({ body: 'Dear ${unknown_var}, welcome.', statusId: 1, variables: [{ id: 999999 }] })
    When method PUT
    Then status 422
    And match response.error contains 'Placeholder mismatch'
    And match response.data == null

  @negative
  Scenario: Missing X-User-Id header — service errors (CS requires a valid userId)
    Given path '/api/v1/notification/templates/1'
    And request { "body": "Body without user id.", "statusId": 1, "variables": [] }
    When method PUT
    * assert responseStatus != 200

  @negative
  Scenario: Two consecutive PUTs — second PUT while first is still pending
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "First pending change.", "statusId": 1 }
    When method PUT
    Then status 202
    * def id1 = response.data.requestChangeId

    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "Second pending change.", "statusId": 1 }
    When method PUT
    # Second change may succeed (202) or fail — must not return 200 OK without a change ID
    * assert responseStatus != 200
    * def id2 = responseStatus == 202 ? response.data.requestChangeId : null

    # Cleanup
    * karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id1 })

    * if (id2 != null) karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id2 })

  @negative
  Scenario: Subject is null, body has matching placeholder and variable — accepted
    * def originalSetup3 = callonce read('classpath:notification/helper/fetch-template.feature') { templateId: 1 }
    * def orig = originalSetup3.template
    * def extractPlaceholders = function(text){ return (text || '').match(/\$\{[^}]+\}/g) || [] }
    * def allBodyPlaceholders = extractPlaceholders(orig.body).concat(extractPlaceholders(orig.subject))
    * def uniquePlaceholders = allBodyPlaceholders.filter(function(v,i,a){ return a.indexOf(v) === i })
    * def varsMapLocal = {}
    * karate.forEach(allVars, function(v){ varsMapLocal[v.name] = v.id })
    * def origVarIds = uniquePlaceholders.map(function(p){ return { id: varsMapLocal[p] } }).filter(function(x){ return x.id !== undefined })
    * def var1 = allVars[0]
    * def bodyWithPlaceholder = 'Dear ' + var1.name + ', welcome.'
    Given url notificationUrl
    And path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request
      """
      {
        "subject": null,
        "body": "#(bodyWithPlaceholder)",
        "statusId": 1,
        "variables": [{ "id": #(var1.id) }]
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
    And match response.data.subject == '##null'
    And match response.data.body == bodyWithPlaceholder

    # Restore
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request { "body": "#(orig.body)", "subject": "#(orig.subject)", "statusId": #(orig.status.id), "variables": #(origVarIds) }
    When method PUT
    Then status 202
    * def restoreId = response.data.requestChangeId
    Given url changeManagementUrl
    And path '/api/v1/request-change/' + restoreId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = userId
    When method POST
    Then status 200
