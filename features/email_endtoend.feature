@end-to-end @email
Feature: XACT API PROD STAGE INT Email end to end tests.

  @QC-2239 @Dev-Safety
  Scenario: End to End email test for all environments.
    Given A non-admin user
    When I POST a new EMAIL message to TMS
    Then I go to Gmail to check for message delivery

  @XACT-619
  Scenario: End to End email test for all environments.
    Given A non-admin user
    When I POST a new EMAIL message to TMS using a non-default from address
    Then I go to Gmail to check for message delivery

  @QC-4386
  Scenario: End to End email test for all environments.
    Given A non-admin user
    When I POST a new EMAIL message to TMS with long macro replacements
    Then I go to Gmail to check for message delivery

  @XACT-698 @pending
  Scenario: admin sends using random from address
    Given An admin user
    When I POST a new EMAIL message to TMS using a random from address
    Then I go to Gmail to check for message delivery
