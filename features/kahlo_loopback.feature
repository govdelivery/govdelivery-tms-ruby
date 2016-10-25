@full-regression @sms @kahlo
Feature: XACT Kahlo loopback tests.

  @webhooks
  Scenario: A Kahlo loopback sender account can send messages and get status updates from kahlo
    Given A kahlo vendor account
    When I send an SMS "naive send" to "+16125554321"
    Then The status is updated within 60 seconds

  @2waysms
  Scenario: A Kahlo loopback vendor can receive messages
    Given A kahlo vendor account
    When "+16125554321" sends an SMS "mos def" and a timestamp to Kahlo loopback
    Then The vendor receives the message and responds with default text

