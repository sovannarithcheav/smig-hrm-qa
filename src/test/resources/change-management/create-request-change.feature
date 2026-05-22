@change-management
Feature: RC-001 Create Request Change

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
        "callbackServiceName": "",
        "requestObjectId": #(uniqueId),
        "requesterRemark": "#(testRemark)"
      }
      """

  @smoke
  Scenario: Happy path - returns 201 with id and PENDING status
    Given path '/api/v1/resource/request-change'
    And header X-User-Id = userId
    And header X-Participant-Id = participantId
    And request validBody
    When method POST
    Then status 201
    And match response.data.id == '#number'
    And match response.error == null

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
