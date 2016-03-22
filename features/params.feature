@full-regression @QC-2239
Feature: Interacting with TMS link tracking params

  @XACT-533-2
  Scenario: Check that params resolve correctly
    When I send an email from an account that has link tracking params configured
    Then those params should resolve within the body of the email I send

  @XACT-533-5
  Scenario: TMS admin verify that link tracking params are only available internally
    Given A non-admin account token
    When I request the accounts api
    Then I should get a forbidden response