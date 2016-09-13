@full-regression @sms @kahlo
Feature: XACT Kahlo loopback tests.

  @webhooks
  Scenario: A Kahlo loopback sender account can send messages and get status updates from kahlo
    Given A kahlo vendor account
      | sending  |
      | sent     |
    When I send an SMS "naive send"
    Then The status is updated within 60 seconds

