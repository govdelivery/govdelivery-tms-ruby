Feature: XACT API PROD, STAGE, INT Email end to end tests.

	Background:

    @QC-2239 @Dev-Safety
	Scenario: End to End email test for all environments.
		When I POST a new EMAIL message to TMS
        Then I go to Gmail to check for message delivery

    @XACT-429
	Scenario: Email header check for all environments
		When I POST an EMAIL message to TMS
        Then I should be able to verify all of the header data is correct


