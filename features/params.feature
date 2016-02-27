@full-regression @QC-2239
Feature: Interacting with TMS link tracking params

  @XACT-533-2
  Scenario: Check that params resolve correctly
    Given I am a TMS admin
    And I send an email from an account that has link tracking params configured
    Then those params should resolve within the body of the email I send

  @XACT-533-5
  Scenario: TMS admin verify that link tracking params are only available internally
    Given I am a TMS user and not an admin
    Then I should not be able to see the accounts endpoint