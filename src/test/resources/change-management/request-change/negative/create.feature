@change-management @request_change @negative
Feature: RC-001 Create Request Change - Negative

  Background:
    * url changeManagementUrl
    # unique requestObjectId per run to avoid ONGOING_REQUESTS conflict
    * def uniqueId = Math.floor(Math.random() * 900000) + 100000
    * def testRemark = karate.scenario.name
    * def validBody =
      """
      {
        "requestObject": { "numAuthorizer": 1 },
        "subject": "authorizer-setting",
        "action": "update",
        "requestObjectId": #(uniqueId),
        "requesterRemark": "#(testRemark)"
      }
      """

  @negative
  Scenario: Missing X-User-Id header - returns 400
    Given path '/api/v1/resource/request-change'
    And header X-Participant-Id = participantId
    And request validBody
    When method POST
    Then status 400
    And match response.error contains 'Missing header'

  @negative
  Scenario: Missing X-Participant-Id header - returns 400
    Given path '/api/v1/resource/request-change'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 400
    And match response.error contains 'Missing header'
