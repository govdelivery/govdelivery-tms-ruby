Feature: XACT Voice end to end test.

  @voice
  Scenario: Create a voice message and send it
    Given I am testing xact voice messaging end to end
    Then I should be able to create a voice message and send to recipients
    And I should be able to verify the voice message was received
