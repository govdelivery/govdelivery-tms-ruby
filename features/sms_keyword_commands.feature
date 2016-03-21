@full-regression @sms
Feature: As a user, if I set up a keyword with a command, that command works.

  @2waysubscribe
  Scenario: XACT Two-Way SMS to Subscribe
    Given I create a subscription keyword and command
    When I send an SMS to create a subscription on TMS
    Then a subscription should be created

  @2waystop
  Scenario: XACT Two-Way SMS to Stop
    Given I am subscribed to receive TMS messages
    And I create a stop keyword and command
    When I send an SMS to opt out of receiving TMS messages
    Then I should receive a STOP response
    And my subscription should be removed

  @static
  Scenario: XACT Two-Way SMS to receive static content
    Given A keyword with static content is configured for an TMS account
    When I send that keyword as an SMS to TMS
    Then I should receive static content

  @forward_command
  Scenario: XACT Two-Way SMS Query of External service
    Given I have an XACT account with a forward worker
    And I register the keyword knowit
    And I register the forward command
    When I text 'knowit 55102' to the forward worker account
    Then I should receive any content as a response
