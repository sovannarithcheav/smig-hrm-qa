@change-management
Feature: RC-001 Create Request Change

  Background:
    * url changeManagementUrl
    * def validBody =
      """
      {
        "requestObject": { "numAuthorizer": 1 },
        "subject": "authorizer-setting",
        "action": "update",
        "callbackServiceName": "change-management",
        "requestObjectId": 1,
        "requesterRemark": "Updating authorizer count"
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
    And match response.data.status == 'PENDING'

  @negative
  Scenario: Missing X-User-Id header - returns 400
    Given path '/api/v1/resource/request-change'
    And header X-Participant-Id = participantId
    And request validBody
    When method POST
    Then status 400
    And match response.message contains 'Missing header'

  @negative
  Scenario: Missing X-Participant-Id header - returns 400
    Given path '/api/v1/resource/request-change'
    And header X-User-Id = userId
    And request validBody
    When method POST
    Then status 400
    And match response.message contains 'Missing header'
