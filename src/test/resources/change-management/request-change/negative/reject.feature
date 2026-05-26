@change-management @request_change @negative
Feature: RC-003 Reject Request Change - Negative

  Background:
    * url changeManagementUrl
    * def testRemark = karate.scenario.name

    # Cancel only OUR OWN pending requests (filtered by requestedBy = userId) so we never
    # touch records belonging to other users in a shared environment.
    Given path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    And params { subject: 'authorizer-setting', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def myPendingIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(myPendingIds, function(id){ karate.call('classpath:change-management/helper/cancel.feature', { cancelId: id }) })

    # Always create a fresh PENDING request for this scenario
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
        "requesterRemark": "#(testRemark)"
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id

  @negative
  Scenario: Missing X-User-Id header - returns 400
    Given path '/api/v1/request-change/' + pendingId + '/reject'
    And header X-Participant-Id = participantId
    And request {}
    When method POST
    Then status 400
    And match response.error == 'Missing header: X-User-Id'
    And match response.data == null

  @negative
  Scenario: Missing X-Participant-Id header - returns 400
    Given path '/api/v1/request-change/' + pendingId + '/reject'
    And header X-User-Id = userId
    And request {}
    When method POST
    Then status 400
    And match response.error == 'Missing header: X-Participant-Id'
    And match response.data == null

  @negative
  Scenario: Non-numeric id - returns 400 with Invalid path parameter
    Given path '/api/v1/request-change/abc/reject'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    And request {}
    When method POST
    Then status 400
    And match response.error == 'Invalid path parameter: id'
    And match response.data == null

  @negative
  Scenario: Non-existent id - returns 400 with REQUEST_CHANGE_NOT_FOUND
    Given path '/api/v1/request-change/999999/reject'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    And request {}
    When method POST
    Then status 400
    And match response.error == 'REQUEST_CHANGE_NOT_FOUND'
    And match response.data == null

  @negative
  Scenario: Wrong participant - returns 400 with PARTICIPANT_MISMATCH
    # Request was created with participantId=2; rejecting with a different participant must fail.
    # This check runs before the health check so it is testable in dev.
    Given path '/api/v1/request-change/' + pendingId + '/reject'
    And header X-User-Id = userId
    And header X-Participant-Id = '999'
    And request {}
    When method POST
    Then status 400
    And match response.error == 'PARTICIPANT_MISMATCH'
    And match response.data == null
