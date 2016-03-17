@voice
Feature: XACT Voice end to end test.
  # TODO this looks like it probably doesn't work at all

  Scenario: Create a voice message and send it
    Given A voice message resource with recipients
    When I POST it
    Then Twilio should complete the call
