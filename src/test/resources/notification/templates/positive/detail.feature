@notification
Feature: NT-002 Notification Template Detail

  Background:
    * url notificationUrl

  @smoke
  Scenario: Valid id - returns enriched template with all fields and correct shape
    Given path '/api/v1/notification/templates/1'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == 1
    And match response.data.name == '#string'
    And match response.data.body == '#string'
    And match response.data.subject == '##string'
    And match response.data.updatedAt == '##string'
    And match response.data.event.id == '#number'
    And match response.data.event.code == '#string'
    And match response.data.event.name == '#string'
    And match response.data.channel.id == '#number'
    And match response.data.channel.name == '#string'
    And match response.data.status.id == '#number'
    And match response.data.status.name == '#string'
    And match response.data.variables == '#array'
    * def varSchema = { id: '#number', label: '#string' }
    * karate.forEach(response.data.variables, function(v){ karate.match(v, varSchema) })

  @smoke
  Scenario: Template with multiple variables - all variables returned
    # Find a template that has at least 2 variables from the actual DB
    Given path '/api/v1/notification/templates'
    And param size = 100
    When method GET
    Then status 200
    * def multiVarTemplate = response.data.content.filter(function(t){ return t.variables.length >= 2 })[0]
    * assert multiVarTemplate != null

    Given path '/api/v1/notification/templates/' + multiVarTemplate.id
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.id == multiVarTemplate.id
    * assert response.data.variables.length >= 2
    * def varSchema = { id: '#number', label: '#string' }
    * karate.forEach(response.data.variables, function(v){ karate.match(v, varSchema) })

  @smoke
  Scenario: Detail is consistent with list response for the same template
    # Fetch first item from list
    Given path '/api/v1/notification/templates'
    And param size = 1
    When method GET
    Then status 200
    * def listItem = response.data.content[0]

    # Fetch same template via detail endpoint
    Given path '/api/v1/notification/templates/' + listItem.id
    When method GET
    Then status 200
    And match response.data.id == listItem.id
    And match response.data.name == listItem.name
    And match response.data.body == listItem.body
    And match response.data.event.id == listItem.event.id
    And match response.data.channel.id == listItem.channel.id
    And match response.data.status.id == listItem.status.id
