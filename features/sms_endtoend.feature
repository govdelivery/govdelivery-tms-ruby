@smoke @XACT-390 @twilio @Test-Support-App @smoke
Feature: XACT SMS end to end tests.
  Scenario: End to End sms test for all environments.
    Given I have a user who can receive SMS messages
    When I POST a new SMS message to TMS
    And I wait for a response from twilio
    Then I should be able to identify my unique message is among all SMS messages
