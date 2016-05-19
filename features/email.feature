@full-regression @QC-2239 @email
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

  @message_types
  Scenario: New EMAIL message with message_type_code in the message
    Given I create an email
    When I set the message_type_code to 'test_message_code'
    And I send the email
    Then the response should have no errors
    And the response should contain a message_type_code with value 'test_message_code'
    And the response should contain a link to the message type