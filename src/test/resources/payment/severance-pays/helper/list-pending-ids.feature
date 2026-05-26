@ignore
Feature: List PENDING severance pay IDs for an employee

  Scenario:
    * url paymentUrl
    Given path '/api/v1/payment/severance-pays'
    And param employeeId = empId
    And param status = 'PENDING'
    When method GET
    Then status 200
    * def ids = response.data.map(function(r){ return { id: r.id } })
