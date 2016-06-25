@end-to-end @sms
Feature: XACT SMS end to end tests.

  @XACT-390 @twilio @Test-Support-App
  Scenario: End to End sms test for all environments.
    Given I have a user who can receive SMS messages
    When I POST a new SMS message to TMS
    And I wait for a response from twilio
    Then I should be able to identify my unique message is among all SMS messages

  @XACT-640 @twilio @pending
  Scenario: End to End sms template test for all environments.
    Given I have a user who can receive SMS messages
    And I have an SMS template
    When I POST a new blank SMS message to TMS
    And I wait for a response from twilio
    Then I should be able to identify my unique message is among all SMS messages

  @mblox
  Scenario: End to End sms test for mblox for all environments.
    When I POST a new SMS message to MBLOX
    Then I should receive either a canceled message or a success
