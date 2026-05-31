@notification
Feature: NT-E2E Send Notification Flow

  # User id=10 (test@smig.com) is the only seeded user in the notification DB.
  # The send endpoint creates a Push subscription automatically for required events.

  Background:
    * url notificationUrl
    * def targetUserId = 10
    * def targetUserIdHeader = '10'

  @e2e
  Scenario: Send notification — saved to history — mark as read — unread count decreases
    # Step 1: Fetch the Push template for PWD_RESET_SUCC to know the expected content
    Given path '/api/v1/notification/templates'
    And params { eventId: 1, channelId: 2 }
    When method GET
    Then status 200
    * def pushTemplate = response.data.content[0]
    * assert pushTemplate != null

    # Step 2: Capture unread count before sending
    Given path '/api/v1/notification/history/unread-count'
    And header X-User-Id = targetUserIdHeader
    When method GET
    Then status 200
    * def countBefore = response.data.count

    # Step 3: Send notification
    Given path '/api/v1/notification/send'
    And header X-User-Id = userId
    And request { userId: #(targetUserId), eventCode: 'PWD_RESET_SUCC', mergeFields: {} }
    When method POST
    Then status 200
    And match response.error == null
    And match response.data == '#[] #notnull'
    And match response.data[0].success == true

    # Step 4: Verify history — latest entry matches sent notification
    Given path '/api/v1/notification/history'
    And header X-User-Id = targetUserIdHeader
    When method GET
    Then status 200
    * def latest = response.data.content[0]
    And match latest.subject == 'PWD_RESET_SUCC'
    And match latest.title == pushTemplate.subject
    And match latest.content == pushTemplate.body
    And match latest.userId == targetUserId
    And match latest.id == '#number'
    * def notificationId = latest.id

    # Step 5: Unread count increased by 1
    Given path '/api/v1/notification/history/unread-count'
    And header X-User-Id = targetUserIdHeader
    When method GET
    Then status 200
    * assert response.data.count == countBefore + 1

    # Step 6: Unread filter returns the new notification
    Given path '/api/v1/notification/history'
    And header X-User-Id = targetUserIdHeader
    And param read = false
    When method GET
    Then status 200
    * def unreadIds = response.data.content.map(function(x){ return x.id })
    * assert unreadIds.indexOf(notificationId) >= 0

    # Step 7: Mark as read
    Given path '/api/v1/notification/history/' + notificationId + '/read'
    And header X-User-Id = targetUserIdHeader
    When method POST
    Then status 204

    # Step 8: Unread count back to before
    Given path '/api/v1/notification/history/unread-count'
    And header X-User-Id = targetUserIdHeader
    When method GET
    Then status 200
    * assert response.data.count == countBefore

    # Step 9: Notification no longer appears in unread filter
    Given path '/api/v1/notification/history'
    And header X-User-Id = targetUserIdHeader
    And param read = false
    When method GET
    Then status 200
    * def unreadIdsAfter = response.data.content.map(function(x){ return x.id })
    * assert unreadIdsAfter.indexOf(notificationId) == -1

  @e2e @negative
  Scenario: Send with unknown eventCode - returns 422 with failure message
    Given path '/api/v1/notification/send'
    And header X-User-Id = userId
    And request { userId: #(targetUserId), eventCode: 'UNKNOWN_EVENT', mergeFields: {} }
    When method POST
    Then status 422
    And match response.error == null
    And match response.data[0].success == false
    And match response.data[0].message contains 'not found'

  @e2e @negative
  Scenario: Send with non-existent userId - returns subscription error
    Given path '/api/v1/notification/send'
    And header X-User-Id = userId
    And request { userId: 999999, eventCode: 'PWD_RESET_SUCC', mergeFields: {} }
    When method POST
    Then status 500
