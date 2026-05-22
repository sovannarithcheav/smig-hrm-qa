@change-management
Feature: RC-002 Approve Request Change

  Background:
    * url changeManagementUrl
    * def uniqueId = Math.floor(Math.random() * 900000) + 100000

    # Create a fresh PENDING request change before each scenario
    Given path '/api/v1/resource/request-change'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    And request
      """
      {
        "requestObject": { "numAuthorizer": 1 },
        "subject": "authorizer-setting",
        "action": "update",
        "callbackServiceName": "",
        "requestObjectId": #(uniqueId)
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id

  # ---------- Positive ----------

  @smoke
  Scenario: Approve PENDING request — approval recorded, state advances past PENDING
    Given path '/api/v1/request-change/' + pendingId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    When method POST
    Then status 200
    And match response.error == null
    And match response.data == {}

    # Verify the approval was recorded and the state machine advanced
    Given path '/api/v1/request-change/report/' + pendingId + '/detail'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.subject == 'authorizer-setting'
    And match response.data.action == 'update'
    And match response.data.statusName != 'pending'
    And match response.data.numResponse == 1
    And match response.data.approvals[0].authorizeStatusName == 'approved'

  # ---------- Negative ----------

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
    # Request was created with participantId=2; approving with a different participant must fail.
    # This check runs before the health check so it is testable in dev.
    Given path '/api/v1/request-change/' + pendingId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = '999'
    When method POST
    Then status 400
    And match response.error == 'PARTICIPANT_MISMATCH'
    And match response.data == null
