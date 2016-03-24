@full-regression @QC-2239 @XACT-533-2
Feature: Interacting with TMS link tracking params

  Scenario: Check that params resolve correctly
    When I send an email from an account that has link tracking params configured
    Then those params should resolve within the body of the email I send
