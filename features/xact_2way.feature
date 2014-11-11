Feature: XACT SMS 2-Way tests.

    @2waysubscribe
	Scenario: XACT 2-Way SMS to Subscribe
		Given I create a subscription keyword and command
		And I send an SMS to create a subscription on TMS
		Then a subscription should be created

	@2waystop
	Scenario: XACT 2-Way SMS to Subscribe
		Given I send an SMS to opt out of receiving TMS messages
		Then I should receive a STOP response
		And a my subscription should be removed

    @2waystatic
    Scenario: XACT 2-Way SMS to receive static content
        Given A keyword with static content is configured for an TMS account
        And I send that keyword as an SMS to TMS
        Then I should receive static content