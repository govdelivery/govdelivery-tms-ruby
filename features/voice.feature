@QC-2237
Feature: Voice messages

  Scenario: TMS create a single voice message to multiple recipients
    When I create a new voice message
    And I add a recipient to the voice message
    And I add another phone number to the message
    And I send the message
    Then the response code should be '201'

  Scenario: List and verify incoming voice messages
    When I create a new voice message
    And I add a recipient to the voice message
    And I send the message
    Then I should see a list of messages with appropriate attributes
    And the response code should be '201'

  Scenario: Verify message detail
    When I create a new voice message
    And I add a recipient to the voice message
    And I send the message
    Then I should be able to verify details of the message
    And the response code should be '201'
