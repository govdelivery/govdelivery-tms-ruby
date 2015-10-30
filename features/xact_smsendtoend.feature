Feature: XACT SMS end to end tests.

    @XACT-390 @Dev-Safety @Twilio @Test-Support-App
	Scenario: End to End sms test for all environments.
		Given I have a user who can receive SMS messages
        And I POST a new SMS message to TMS
        And I wait for a response from twilio
        Then I should be able to identify my unique message is among all SMS messages


    @mblox
	Scenario: End to End sms test for mblox for all environments.
        Given I POST a new SMS message to MBLOX
        And I wait for a response from TMS
        Then I should receive either a canceled message or a success