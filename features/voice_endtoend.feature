@end-to-end @twilio @voice
Feature: XACT Voice end to end test.

  Scenario: Create a voice message and send it
    Given A voice message resource with recipients
    When I POST it
    Then Twilio should have an active call
    And Twilio should complete the call
