@full-regression @QC-2239
Feature: Interacting with TMS link tracking params

  @XACT-533-2
  Scenario: Check that params resolve correctly
    And I send an email from an account that has link tracking params configured
    Then those params should resolve within the body of the email I send
