@full-regression @QC-2237
Feature: Voice messages

  Scenario: TMS create a single voice message to multiple recipients
    Given I created a new voice message
    When I add phone number '+16124679346' to the message
    And I add phone number '+16123145807' to the message
    And I send the message
    Then the response code should be '201'

  Scenario: List and verify incoming voice messages
    Given I created a new voice message
    When I add phone number '+16124679346' to the message
    And I send the message
    Then I should see a list of messages with appropriate attributes
    And the response code should be '201'

  Scenario: Verify message detail
    Given I created a new voice message
    When I add phone number '+16124679346' to the message
    And I send the message
    Then I should be able to verify details of the message
    And the response code should be '201'
