@full-regression @email @template
Feature: Interacting with TMS email templates

  Background:
    Given I am using a non-admin TMS client

  Scenario: TMS admin verify that templates are created with provided values
    Given I build an email template
    When I save the email template
    Then the response code should be '201'

  Scenario: TMS admin verify that templates can be updated
    Given an email template exists
    When I update the body to 'a new body'
    And I update the email template
    Then the template should have body 'a new body'
    And the response code should be '200'

  Scenario: TMS admin verify that templates can be retreived
    Given an email template exists
    When I get the email template
    Then the response code should be '200'

  Scenario: TMS admin verify that templates can be deleted
    Given an email template exists
    When I delete the email template
    Then the response code should be '204'
    And the template should no longer exist

  Scenario: TMS posting a new EMAIL message with a template and nothing else
    Given an email template exists
    When I send an EMAIL message specifying just that template and a recipient
    Then the message should have the attributes from the template

  Scenario: TMS posting a new EMAIL message with a template and everything else
    Given an email template exists
    When I send an email with everything specified and a template
    Then Open tracking should be disabled
    And Click tracking should be disabled
    And the message should have "body" set to "specified my body"
    And the message should have macro 'city' => 'St Paul'

  @QC-UUID-EMAIL_BLANK_STRING
  Scenario: Verifying whether a new email template with "" uuid will return a uuid as id
    Given I build an email template with uuid ''
    When I save the email template
    Then I should expect the uuid and the id to be the same for the email template

  @QC-UUID-EMAIL
  Scenario: Verifying whether UPDATE works for uuid email templates
    Given an email template exists
    When I update the uuid to 'new_uuid'
    And I update the email template
    Then the response code should be '422'
    And the uuid should not be 'new_uuid'

  @message_types
  Scenario: TMS admin verifies that a template can be created with a message_type_code
    Given I build an email template
    And I set the message_type_code on the template to 'test_template_message_type_code'
    When I save the email template
    Then the response code should be '201'
    And the template response should contain a message_type_code with value 'test_template_message_type_code'
    And the template response should contain a link to the message type

  @message_types
  Scenario: TMS admin verifies that a template without a message_type_code can be updated with a message_type_code
    Given an email template exists
    When I update the message_type_code on the template to 'test_update_template_message_type_code'
    And I update the email template
    Then the response code should be '200'
    And the template response should contain a message_type_code with value 'test_update_template_message_type_code'
    And the template response should contain a link to the message type

  @message_types
  Scenario: TMS admin verifies that a template with a message_type_code can be updated with a new message_type_code
    Given an email template exists with a message_type_code 'before_message_type_code'
    When I update the message_type_code on the template to 'after_message_type_code'
    And I update the email template
    Then the response code should be '200'
    And the template response should contain a message_type_code with value 'after_message_type_code'
    And the template response should contain a link to the message type

  @message_types
  Scenario: TMS admin verifies that a template with a message_type_code can be updated to remove message_type_code
    Given an email template exists with a message_type_code 'before_message_type_code'
    When I remove the message_type_code from the template
    And I update the email template
    Then the response code should be '200'
    And the response should not contain a message_type_code
    And the response should not contain a link to the message type

  @message_types
  Scenario: TMS posting a new EMAIL message without a message_type_code but with a message_type_code template
    Given an email template exists with a message_type_code 'sending_test_message_type_code'
    When I send an EMAIL message specifying just that template and a recipient
    Then the message should have the attributes from the template
    And the response should contain a message_type_code with value 'sending_test_message_type_code'
    And the response should contain a link to the message type

  @message_types
  Scenario: TMS posting a new EMAIL message with a message_type_code and message_type_code template
    Given an email template exists with a message_type_code 'sending_test_message_type_code'
    When I send an EMAIL message specifying just that template and a recipient and message_type_code 'overridden_message_type_code'
    Then the message should have the attributes from the template
    And the response should contain a message_type_code with value 'overridden_message_type_code'
    And the response should contain a link to the message type

  @message_types
  Scenario: TMS posting a new EMAIl message with a message_type_code and a non message_type_code template
    Given an email template exists
    When I send an EMAIL message specifying just that template and a recipient and message_type_code 'added_message_type_code'
    Then the message should have the attributes from the template
    And the response should contain a message_type_code with value 'added_message_type_code'
    And the response should contain a link to the message type
