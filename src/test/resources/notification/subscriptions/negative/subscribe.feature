@notification @subscriptions @negative
Feature: NT-SUB-N-001 Subscribe — validation errors

  Background:
    * url notificationUrl

  Scenario: Missing X-User-Id header returns 401
    Given path '/api/v1/notification/subscriptions/subscribe'
    And request { channelId: 1 }
    When method POST
    Then status 401
    And match response == 'Missing X-User-Id header'
