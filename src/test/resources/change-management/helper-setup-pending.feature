@ignore
Feature: Cancel own PENDING requests and create one shared PENDING for the test suite

  Scenario:
    # Cancel any of our own PENDING records before creating a fresh one
    Given url changeManagementUrl
    And path '/api/v1/request-change/report/for/requesters'
    And header X-User-Id = userId
    And params { subject: 'authorizer-setting', action: 'update', statusId: 1, size: 100 }
    When method GET
    Then status 200
    * def myPendingIds = response.data.content.map(function(x){ return x.id })
    * karate.forEach(myPendingIds, function(id){ karate.call('classpath:change-management/helper-cancel.feature', { cancelId: id }) })

    # Create the single shared PENDING request for the test suite
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
        "requesterRemark": "test suite shared pending"
      }
      """
    When method POST
    Then status 201
    * def pendingId = response.data.id
