@notification @templates @negative
Feature: NT-003 Update Notification Template - Negative

  Background:
    # Fetch all variables from DB once — used in scenarios that need a real variable id + label
    * def varSetup = callonce read('classpath:notification/helper/fetch-variables.feature') {}
    * def allVars  = varSetup.variables
    * def testVar  = allVars[0]
    * url notificationUrl

  @negative
  Scenario: Non-numeric id - returns 400
    Given path '/api/v1/notification/templates/abc'
    And header X-User-Id = userId
    And request { "body": "Hello", "statusId": 1 }
    When method PUT
    Then status 400
    And match response.error contains 'Invalid'
    And match response.data == null

  @negative
  Scenario: Non-existent id - returns 404
    Given path '/api/v1/notification/templates/999999'
    And header X-User-Id = userId
    And request { "body": "Hello", "statusId": 1 }
    When method PUT
    Then status 404
    And match response.error != null
    And match response.data == null

  @negative
  Scenario: Placeholder in body but no variable declared - returns 422
    * def testBody = 'Dear ' + testVar.name + ', your password has been reset.'
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request ({ body: testBody, statusId: 1, variables: [] })
    When method PUT
    Then status 422
    And match response.error contains 'Placeholder mismatch'
    And match response.data == null

  @negative
  Scenario: Variable declared but placeholder missing from body - returns 422
    Given path '/api/v1/notification/templates/1'
    And header X-User-Id = userId
    And request ({ body: 'No placeholder here.', statusId: 1, variables: [{ id: testVar.id }] })
    When method PUT
    Then status 422
    And match response.error contains 'Placeholder mismatch'
    And match response.data == null
