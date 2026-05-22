@ignore
Feature: Create a PENDING authorizer-setting request change

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
        "callbackServiceName": "",
        "requestObjectId": 1,
        "requesterRemark": "#(testRemark)"
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id
