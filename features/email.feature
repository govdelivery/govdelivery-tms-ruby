@full-regression @QC-2239
Feature: Tests around sending emails

  Scenario: TMS verify the ability to disable click tracking in my EMAIL sends
    Given I create an email
    When I disable Click tracking
    And I send the email
    Then Click tracking should be disabled
    And the message should have no errors

  Scenario: TMS verify the ability to disable open tracking in my EMAIL sends
    Given I create an email
    When I disable Open tracking
    And I send the email
    Then Open tracking should be disabled
    And the message should have no errors

  Scenario: New EMAIL with message and recipient MACROS
    Given I create an email
    When I add the macro 'city' => 'St Paul'
    And I set the body to 'Regression test [[city]]'
    And I send the email
    Then the message should have macro 'city' => 'St Paul'
    And the response should have no errors

  Scenario: New EMAIL message with an empty BODY produces an Unprocessable Entity error
    Given I create an email
    When I set the body to ''
    And I send the email
    Then I should receive the error "can't be blank" in the "body" payload
    And the response code should be '422'

  Scenario: New EMAIL message with an empty SUBJECT produces an Unprocessable Entity error
    Given I create an email
    When I set the subject to ''
    And I send the email
    Then I should receive the error "can't be blank" in the "subject" payload
    And the response code should be '422'

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

  Scenario: New EMAIL message and retrieve the list recipient counts/states
    Given I create an email
    When I send the email
    Then the response body should contain valid _links

  Scenario: New EMAIL message with HTML within the message body
    Given I create an email
    When I set the body to '<p><a href="http://govdelivery.com">Test</a>'
    And I send the email
    Then the response should have no errors

  Scenario: New EMAIL message with inline CSS in the message
    Given I create an email
    When I set the body to 'A message with CSS. <div style=\"background-color:#c0c0c0;">TEXT</div>'
    And I send the email
    Then the response should have no errors

  Scenario: New EMAIL message with one VALID and one INVALID RECIPIENT produces a Created response and a failed recipient
    Given I create an email
    When I add recipient 'govdelivery.com'
    And I send the message
    Then the response should have no errors
    And the response should have a failed recipient
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
