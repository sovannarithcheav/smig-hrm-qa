@ignore
Feature: Create one shared PENDING request for the test suite

  Scenario:
    Given url changeManagementUrl
    And path '/api/v1/resource/request-change'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    And request
      """
      {
        "requestObject": { "numAuthorizer": 1 },
        "subject": "authorizer-setting",
        "action": "update",
        "requestObjectId": 1,
        "requesterRemark": "test suite shared pending"
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id
