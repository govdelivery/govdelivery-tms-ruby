@full-regression @sms
Feature: Interacting with TMS sms templates

  @QC-UUID-SMS_BLANK_STRING
  Scenario: Verifying whether a new sms template with "" uuid will return a uuid as id
  When I create a new sms template with "" uuid
  Then I should expect the uuid and the id to be the same for the sms template

  @QC-UUID-SMS
  Scenario: Verifying whether UPDATE works for uuid sms templates
    When I have an SMS template
    Then I should not be able to update the sms template with "new_uuid" uuid