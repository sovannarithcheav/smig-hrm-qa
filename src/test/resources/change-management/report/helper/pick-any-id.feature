@ignore
Feature: Helper - pick any existing request change id from the admin list

  Scenario:
    Given url changeManagementUrl
    And path '/api/v1/request-change/report/for/admins'
    When method GET
    Then status 200
    * def anyId = response.data.content.length > 0 ? response.data.content[0].id : null
