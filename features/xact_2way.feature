Feature: XACT SMS 2-Way tests.

    @2waysubscribe
	Scenario: XACT 2-Way SMS to Subscribe
		Given I create a subscription keyword and command
		And I send an SMS to create a subscription on TMS
		Then a subscription should be created

	@2waystop
	Scenario: XACT 2-Way SMS to Stop
		Given I send an SMS to opt out of receiving TMS messages
		Then I should receive a STOP response
		And a my subscription should be removed

    @keyword
    Scenario: XACT 2-Way SMS to receive static content
        Given A keyword with static content is configured for an TMS account
        And I send that keyword as an SMS to TMS
        Then I should receive static content

    @keyword
    Scenario: XACT 2-Way SMS Real Time Query of Bart
      Given I have an XACT account for BART
      And I register the keyword BART
      And I register the BART forward command
      When I text 'BART 12th' to the BART account
      Then I should receive BART content as a response
