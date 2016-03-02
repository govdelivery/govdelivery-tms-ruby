@full-regression
Feature: Validate interaction with from addresses

  Scenario: TMS admin verify that from addresses can be listed and read
    When I get the list of from addresses
    Then I should be able to list and read from addresses