@end-to-end @email
Feature: XACT API PROD STAGE INT Email end to end tests.

  @QC-2239 @Dev-Safety @patching
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

  @XACT-758
  Scenario: End to End email using from address with from name overriding from name
    Given A non-admin user
    When I POST a new EMAIL message to TMS with message-level from name using a from address with a from name
    Then I go to Gmail to check for message delivery

  @XACT-758
  Scenario: End to End email using from_address with nil from name
    Given A non-admin user
    When I POST a new EMAIL message to TMS with a from_address with 'nil' as the from name
    Then I go to Gmail to check for message delivery

  @XACT-758
  Scenario: End to End email using from_name from from_address
    Given A non-admin user
    When I POST a new EMAIL message to TMS with a from_address with 'something' as the from name
    Then I go to Gmail to check for message delivery

  @XACT-758
  Scenario: End to End email using from address with no from name with a message-level from name
    Given A non-admin user
    When I POST a new EMAIL message to TMS with a message-level from name
    Then I go to Gmail to check for message delivery
