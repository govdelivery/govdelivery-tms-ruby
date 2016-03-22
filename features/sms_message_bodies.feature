@full-regression @QC-1976
Feature: SMS Message Bodies

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