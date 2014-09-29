Feature: XACT Webhooks functionality
In order to be informed on the progress of a message sent to a recipient
As a client developer
I want to be notified whenever the state of a recipient changes

@webhooks
Scenario: Invoke the webhook of every recipient event type on email messages
  Given the following event type
  And a callback url exists for each event type
  And a callback url is registered for each event_type
  When I send an email message to the magic address of each event state
  Then the callback registered for each event state should receive a POST referring to the appropriate message

