@change-management
Feature: RC-002 Approve Request Change

  Background:
    * url changeManagementUrl
    * def testRemark = karate.scenario.name

    # Reuse any existing PENDING request — prefer requestObjectId=1 (smoke needs it for callback),
    # accept any other requestObjectId (fine for all negative scenarios).
    # Create a new one only when nothing is pending at all.
    Given path '/api/v1/request-change/report/for/admins'
    And params { subject: 'authorizer-setting', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def allPending  = response.data.content
    * def preferred   = allPending.filter(function(x){ return x.requestObjectId == 1 })
    * def pendingId   = preferred.length > 0 ? preferred[0].id : (allPending.length > 0 ? allPending[0].id : null)
    * def created     = pendingId == null ? karate.call('classpath:change-management/helper-create.feature', { testRemark: testRemark }) : null
    * def pendingId   = pendingId != null ? pendingId : created.pendingId

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
    And match response.data.statusName == 'updated'
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
