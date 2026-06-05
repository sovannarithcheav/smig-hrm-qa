@ignore
Feature: helper - create a throwaway user via the write-flow (submit + approve) and return its id

  # Inputs (call args): username, primaryRoleId, secondaryRoleIds (array), fullName (optional)
  Scenario: create-user
    * def adminLogin = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * def fullName = (typeof fullName == 'undefined' ? 'QA Throwaway' : fullName)
    * def secondaryRoleIds = (typeof secondaryRoleIds == 'undefined' ? [] : secondaryRoleIds)

    * url userUrl
    Given path '/api/v1/user/users'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And request { username: '#(username)', fullName: '#(fullName)', primaryRoleId: '#(primaryRoleId)', secondaryRoleIds: '#(secondaryRoleIds)' }
    When method POST
    Then status 202
    And match response.data.requestChangeId == '#number'
    * def requestChangeId = response.data.requestChangeId

    * call read('classpath:user/write/helper/approve.feature') { requestChangeId: '#(requestChangeId)' }

    # resolve the created user's id (username is unique per run)
    Given path '/api/v1/user/users'
    And header Authorization = 'Bearer ' + adminLogin.accessToken
    And param q = username
    When method GET
    Then status 200
    And match response.data.content[0].username == username
    * def createdUserId = response.data.content[0].id
    * def adminToken = adminLogin.accessToken
