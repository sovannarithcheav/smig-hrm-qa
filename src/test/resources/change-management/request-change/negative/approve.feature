@change-management
Feature: RC-002 Approve Request Change - Negative

  Background:
    * url changeManagementUrl

    # Cancel any existing pending requests so we start clean
    Given path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    And params { subject: 'authorizer-setting', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def myPendingIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(myPendingIds, function(id){ karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id }) })

    # Create a fresh PENDING request for this scenario
    Given path '/api/v1/resource/request-change'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    And request
      """
      {
        "requestObject": { "numAuthorizer": 1 },
        "subject": "authorizer-setting",
        "action": "update",
        "requestObjectId": 1,
        "requesterRemark": "approve negative test setup"
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id

  @negative
  Scenario: Missing X-User-Id header - returns 400
    Given path '/api/v1/request-change/' + pendingId + '/approve'
    And header X-Participant-Id = participantId
    When method POST
    Then status 400
    And match response.error == 'Missing header: X-User-Id'
    And match response.data == null

  @negative
  Scenario: Missing X-Participant-Id header - returns 400
    Given path '/api/v1/request-change/' + pendingId + '/approve'
    And header X-User-Id = userId
    When method POST
    Then status 400
    And match response.error == 'Missing header: X-Participant-Id'
    And match response.data == null

  @negative
  Scenario: Non-numeric id - returns 400 with Invalid path parameter
    Given path '/api/v1/request-change/abc/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    When method POST
    Then status 400
    And match response.error == 'Invalid path parameter: id'
    And match response.data == null

  @negative
  Scenario: Non-existent id - returns 400 with REQUEST_CHANGE_NOT_FOUND
    Given path '/api/v1/request-change/999999/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    When method POST
    Then status 400
    And match response.error == 'REQUEST_CHANGE_NOT_FOUND'
    And match response.data == null

  @negative
  Scenario: Wrong participant - returns 400 with PARTICIPANT_MISMATCH
    Given path '/api/v1/request-change/' + pendingId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = '999'
    When method POST
    Then status 400
    And match response.error == 'PARTICIPANT_MISMATCH'
    And match response.data == null
