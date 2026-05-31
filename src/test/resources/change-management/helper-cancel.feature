@ignore
Feature: Cancel a request change (best-effort, ignores already-finalized errors)

  Scenario:
    Given url changeManagementUrl
    And path '/api/v1/resource/request-change/' + cancelId + '/cancel'
    When method POST
    * def ignored = responseStatus
