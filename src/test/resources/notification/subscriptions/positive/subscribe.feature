@notification @subscriptions @positive
Feature: NT-SUB-002 Subscribe

  Background:
    * url notificationUrl

  @smoke
  Scenario: Subscribe to Email channel returns 200
    Given path '/api/v1/notification/subscriptions/subscribe'
    And header X-User-Id = userId
    And header X-Username = 'admin'
    And header X-Role-Type = 'ADMIN'
    And request { channelId: 1 }
    When method POST
    Then status 200
    And match response.error == null
