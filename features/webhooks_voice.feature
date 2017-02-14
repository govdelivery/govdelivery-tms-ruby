@webhooks @Test-Support-App
Feature: XACT Voice Webhooks functionality

  Scenario Outline: Invoke the webhook of every recipient event type on voice messages
    Given a callback url exists for <event_type>
    When I send a voice message to magic address for event <event_type>
    And I wait for the message recipients to be built
    And I wait for the recipient to have an event status of <event_type>
    And I wait for the callback payload to contain my uri
    Then the callback payload should be non-nil
    And the callback should receive a POST
    Examples:
      |event_type  |
      |sending     |
      |sent        |
      |failed      |
      |blacklisted |
      |inconclusive|
      |canceled    |
