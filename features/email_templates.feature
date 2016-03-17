@full-regression
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
