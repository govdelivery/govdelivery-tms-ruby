@full-regression @QC-1976
Feature: Sending SMS messages

  @QC-2234
  Scenario: TMS posting a new SMS message with over 160 characters in the message body to a PHONE NUMBER produces a 422 Unprocessable response.
    When I post a new SMS message with too many characters
    Then I should receive the error "is too long (maximum is 160 characters)" in the "body" payload
    And the response code should be '422'

  @QC-2235
  Scenario: TMS posting a new SMS message with under 160 characters in the message body to a PHONE NUMBER produces a 201 Created response.
    When I post a new SMS message with the correct number of characters
    Then the response code should be '201'

  @QC-2236
  Scenario: TMS posting a new SMS message with under 160 characters in the message body to a FORMATTED PHONE NUMBER produces a 201 Created response.
    When I post a new SMS message with the correct number of characters to a formatted phone number
    Then the response code should be '201'

  @QC-2240
  Scenario: TMS retrieve a message detail on a sent SMS
    When I post a new SMS message and retrieve the message details
    Then the response code should be '200'

  @QC-2241
  Scenario: TMS retrieve a recipient detail on a sent SMS
    When I post a new SMS message and retrieve the recipient details
    Then the response code should be '200'

  @QC-2422
  Scenario: TMS posting a new SMS message to MULTIPLE RECIPIENTS
    When I post a new SMS message to multiple recipients
    Then the response code should be '201'

  @QC-2476
  Scenario: TMS posting a new SMS message with a body under 160 characters and NO PHONE NUMBER should produce an error.
    When I post a new SMS message to an empty recipient
    Then I should receive the error "must contain at least one valid recipient" in the "recipients" payload
    And the response code should be '422'

  @QC-2477
  Scenario: TMS posting a new SMS message to MULTIPLE RECIPIENTS where two which are INVALID and produces two FAILED recipients.
    When I post a new SMS message to invalid recipients I should not receive failed recipients
    Then the response code should be '201'

  @QC-2478
  Scenario: TMS posting a new SMS message with DUPLICATE phone numbers.
    When I post a new SMS message with duplicate recipients
    Then the response code should be '201'

  @QC-3011
  Scenario: TMS posting a new SMS message which contains special characters.
    When I post a new SMS message which contains special characters
    Then the response code should be '201'