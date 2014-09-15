@webhooks
Feature: XACT Webhooks functionality
In order to be informed on the progress of a message sent to a recipient
As a client developer
I want to be notified whenever the state of a recipient changes

Background:
  Given The following event types:
    | event_type   |
    | sending      |
    | sent         |
    | failed       |
    | blacklisted  |
    | inconclusive |
    | canceled     |
#Before global hook in env.rb runs before scenario tests to create /account, and After global hook runs after to teardown.

Scenario: 
  When placeholder
  Then something

Scenario: Invoke the webhook of every recipient event type on email messages
  Given A callback url exists for each state
  And A callback url is registered for each event state
  When I send an email message to the magic address of each event state
  Then The callback registered for each event state should receive a POST referring to the appropriate message

Scenario: Invoke the webhook of every recipient event type on SMS messages
  Given A callback url exists for each state
  And A callback url is registered for each event state
  When I send an SMS message to the magic number of each event state
  Then The callback registered for each event state should receive a POST referring to the appropriate message