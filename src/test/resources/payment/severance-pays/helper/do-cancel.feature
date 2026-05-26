@ignore
Feature: Cancel a single severance pay record (best-effort, ignores errors)

  Scenario:
    * url paymentUrl
    * path '/api/v1/payment/severance-pays/' + id + '/cancel'
    * header X-User-Id = userId
    * method post
    * def ignored = responseStatus
