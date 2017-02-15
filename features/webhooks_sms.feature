@webhooks @Test-Support-App
Feature: XACT SMS Webhooks functionality
  Scenario: Invoke the webhook of every recipient event type on sms messages
    Given a random event_type
    And a callback url exists for the event_type
    When I send an sms message to magic address for the event_type
    And I wait for the message recipients to be built
    And I wait for the recipient to have an event status of the event_type
    And I wait for the callback payload to contain my uri
    Then the callback payload should be non-nil
    And the callback should receive a POST
