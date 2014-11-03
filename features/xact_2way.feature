Feature: XACT SMS 2-Way tests.

    @2waysubscribe
	Scenario: XACT 2-Way SMS to Subscribe
		Given I send an SMS to create a subscription on TMS
		Then I should receive a SUBSCRIBE response
		And a subscription should be created

	@2waystop
	Scenario: XACT 2-Way SMS to Subscribe
		Given I send an SMS to opt out of receiving TMS messages
		Then I should receive a STOP response
		And a my subscription should be removed