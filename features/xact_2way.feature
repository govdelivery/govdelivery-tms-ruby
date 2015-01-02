Feature: XACT SMS 2-Way tests.

    @2waysubscribe @keyword @Dev-Safety
	Scenario: XACT 2-Way SMS to Subscribe
		Given I create a subscription keyword and command
		And I send an SMS to create a subscription on TMS
		Then a subscription should be created

	@2waystop @keyword @Dev-Safety
	Scenario: XACT 2-Way SMS to Stop
		Given I am subscribed to receive TMS messages
    And I create a stop keyword and command
    When I send an SMS to opt out of receiving TMS messages
		Then I should receive a STOP response
		And my subscription should be removed

  @keyword
  Scenario: XACT 2-Way SMS to receive static content
    Given A keyword with static content is configured for an TMS account
    And I send that keyword as an SMS to TMS
    Then I should receive static content

  @keyword @bart
  Scenario: XACT 2-Way SMS Real Time Query of Bart
    Given I have an XACT account for BART
    And I register the keyword BART
    And I register the BART forward command
    When I text 'BART 12th' to the BART account
    Then I should receive BART content as a response

  @keyword @acetrain
  Scenario: XACT 2-Way SMS Real Time Query of ACETrain
    Given I have an XACT account for ACETrain
    And I register the keyword frmnt
    And I register the ACETrain forward command
    When I text 'frmnt' to the ACETrain account
    Then I should receive ACETrain content as a response

  @keyword @cdc
  Scenario: XACT 2-Way SMS Real Time Query of CDC's KnowIt
    Given I have an XACT account for CDC
    And I register the keyword knowit
    And I register the CDC forward command
    When I text 'knowit 55102' to the CDC account
    Then I should receive CDC content as a response
