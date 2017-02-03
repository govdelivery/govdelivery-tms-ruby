Feature: Interacting with TMS Message Types API.

  Background:
    Given I am using a non-admin TMS client

  Scenario: Create a message type
    When I create a message type with code prefix 'create_message_type_testing'
    Then the message type was created
    And the message type code starts with 'create_message_type_testing'
    And the message type user visible text starts with 'Create Message Type Testing'

  Scenario: Update a message type
    Given a message type exists with code prefix 'update_message_type_testing'
    When I update the message type with user visible text 'New Message Type Testing'
    Then the message type code starts with 'update_message_type_testing'
    And the message type user visible text is 'New Message Type Testing'

  Scenario: Listing message types in an account without an email vendor
    When I list message types in an account without an email vendor
    Then the client should not have message_types

  Scenario: Listing message types in an account with message types
    Given a message type exists with code 'listing_message_type_testing'
    When I list message types
    Then the listing should include a message type with code 'listing_message_type_testing'

  Scenario: Delete a message type
    Given a message type exists with code prefix 'delete_message_type_testing'
    When I delete the message type with code prefix 'delete_message_type_testing'
    And I list message types
    Then the listing should not include a message type with code prefix 'delete_message_type_testing'

  Scenario: Delete a message type after adding it to a message
    Given an email message exists with a message_type_code 'delete_template_message_type'
    Then that message type cannot be deleted
