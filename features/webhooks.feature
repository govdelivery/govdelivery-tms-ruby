@full-regression @webhooks @Test-Support-App
Feature: XACT Webhooks functionality
In order to be informed on the progress of a message sent to a recipient
As a client developer
I want to be notified whenever the state of a recipient changes

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

  Scenario Outline: Invoke the webhook of every recipient event type on sms messages
    Given a callback url exists for <event_type>
    When I send an sms message to magic address for event <event_type>
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

  Scenario Outline: Invoke the webhook of every recipient event type on email messages
    Given a callback url exists for <event_type>
    When I send an email message to magic address for event <event_type>
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