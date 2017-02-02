@QC-2239
Feature: Validate interaction with recipeints

  Scenario: TMS admin verify that from addresses can be listed and read
    Given A Gmail recipient
    When I get the list of from addresses
    Then I should be able to list and read from addresses

  Scenario: New EMAIL message with one VALID and one INVALID RECIPIENT produces a Created response with only one recipient
    Given I create an email
    When I add recipient 'govdelivery.com'
    And I send the message
    Then the response should have no errors
    And the response should have only one recipient
    And the response code should be '201'

  Scenario: New EMAIL message with an empty FROM_EMAIL produces an Unprocessable Entity error
    Given I create an email
    When I set the from email to ''
    And I send the email
    Then I should receive the error "can't be blank" in the "from_email" payload
    And the response code should be '422'

  Scenario: New EMAIL message with an empty REPLY_TO produces a Created response and defaults to the account level FROM_ADDRESS.
    Given I create an email
    When I send the email
    Then the response code should be '201'
    And the reply to address should be the from email address

  Scenario: New EMAIL message with an empty ERRORS_TO produces a Created response and defaults to the account level ERRORS_TO
    Given I create an email
    When I send the email
    Then the errors to address should default to the account level errors to email

  Scenario: New EMAIL message with an invalid FROM_EMAIL produces an Unprocessable Entity error
    Given I create an email
    When I set the from email to 'test@foo.bar'
    And I send the email
    Then I should receive the error "is not authorized to send on this account" in the "from_email" payload

  Scenario: New EMAIL message to multiple RECIPIENTS
    Given I create an email
    When I add recipient 'regressiontest2@sink.govdelivery.com'
    And I send the message
    Then the response should have no errors

  Scenario: New EMAIL message with no RECIPIENTS produces an Unprocessable Entity error
    Given I create an email with no recipients
    When I send the email
    Then I should receive the error "must contain at least one valid recipient" in the "recipients" payload
    And the response code should be '422'
