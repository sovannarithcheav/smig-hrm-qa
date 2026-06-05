@user @functionalities @positive
Feature: US Functionalities - list

  Background:
    * def login = call read('classpath:user/helper/login.feature') { username: 'admin', password: 'aA12345@' }
    * url userUrl
    * header Authorization = 'Bearer ' + login.accessToken

  # total is >= 14, not == 14: functionality write-flow tests create extra functionalities in the shared dev DB.
  Scenario: list returns at least the 14 seed functionalities with pagination envelope
    Given path '/api/v1/user/functionalities'
    When method GET
    Then status 200
    And match response.error == null
    And match response.data.pagination.total == '#? _ >= 14'
    And match response.data.content[*].code contains ['USER', 'ROLE', 'SESSION', 'PAYROLL_RUN']

  Scenario: q filters by code
    Given path '/api/v1/user/functionalities'
    And param q = 'PAYROLL'
    When method GET
    Then status 200
    And match response.data.pagination.total == 2
    And match each response.data.content[*].code contains 'PAYROLL'

  Scenario: pagination page/size
    Given path '/api/v1/user/functionalities'
    And param size = 5
    And param page = 0
    When method GET
    Then status 200
    And match response.data.content == '#[5]'
    # >= 3 (ceil(14/5)); write-flow tests may add functionalities to the shared dev DB.
    And match response.data.pagination.totalPages == '#? _ >= 3'

  Scenario: status filter (none deactivated in seed)
    Given path '/api/v1/user/functionalities'
    And param status = 'DEACTIVATED'
    When method GET
    Then status 200
    And match response.data.pagination.total == 0
