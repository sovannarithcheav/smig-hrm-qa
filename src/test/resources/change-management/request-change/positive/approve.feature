@change-management
Feature: RC-002 Approve Request Change

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
        "requesterRemark": "approve test setup"
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id

  @smoke
  Scenario: Approve PENDING request — approval recorded, state advances past PENDING
    Given path '/api/v1/request-change/' + pendingId + '/approve'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    When method POST
    Then status 200
    And match response.error == null
    And match response.data == {}

    Given path '/api/v1/request-change/report/' + pendingId + '/detail'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.subject == 'authorizer-setting'
    And match response.data.action == 'update'
    And match response.data.statusName == 'updated'
    And match response.data.numResponse == 1
    And match response.data.approvals[0].authorizeStatusName == 'approved'
