
#####################################################
# Given
#####################################################

Given(/^a callback url exists for (.*)$/) do |event_type|
  @event_callback_uri = @capi.create_callback_uri(:recipient_status, event_type)
  @client = TmsClientManager.from_configatron(configatron.accounts.webhooks)
  webhook = @client.webhooks.build(url: @capi.callback_domain + @event_callback_uri, event_type: event_type)
  webhook.post!
  @webhooks << webhook
end

#####################################################
# When
#####################################################

When(/^I send a voice message to magic address for event (.*)$/) do |event|
  phone = configatron.accounts.webhooks.magic.phone[event]
  @message = @client.voice_messages.build(play_url: 'http://www.webhooks-testing.com')
  @message.recipients.build(phone: phone)
  @message.post!
end

When(/^I send an sms message to magic address for event (.*)$/) do |event|
  phone = configatron.accounts.webhooks.magic.phone[event]
  @message = @client.sms_messages.build(body: 'Webhooks Testing')
  @message.recipients.build(phone: phone)
  @message.post!
end

When(/^I send an email message to magic address for event (.*)$/) do |event|
  email = configatron.accounts.webhooks.magic.email[event]
  @message = @client.email_messages.build(body: 'Webhooks Testing', subject: "webhook test #{environment} - #{Time.now}")
  @message.recipients.build(email: email)
  @message.post!
end

When(/^I wait for the message recipients to be built$/) do
  GovDelivery::Proctor.backoff_check(5.minutes, 'recipient list is being built') do
    begin
      @message.recipients.get
    rescue GovDelivery::TMS::Request::InProgress
      false
    end
  end
end

When(/^I wait for the recipient to have an event status of (.*)/) do |status_type|
  @recipient = @message.recipients.collection.first
  GovDelivery::Proctor.backoff_check(1.minute, 'arrive at expected status') do
    @recipient.get
    status_type == @recipient.attributes[:status]
  end
end

When(/^I wait for the callback payload to contain my uri$/) do
  @event_callback = nil

  GovDelivery::Proctor.backoff_check(5.minutes, "have at least 1 callback") do
    @event_callback = @capi.get(@event_callback_uri)
    @event_callback['payload_count'] >= 1
  end
end

#####################################################
# Then
#####################################################

Then(/^the callback payload should be non-nil$/) do
  raise "Callback should have non-nil payloads - callback endpoint: #{@event_callback}" if @event_callback['payloads'].nil?
end

Then(/^the callback should receive a POST$/) do
  GovDelivery::Proctor.backoff_check(1.minute, 'have all payloads expected') do
    condition = xact_url + @recipient.href
    payloads = @event_callback['payloads'].map { |payload_info| @capi.get(payload_info['url']) }
    payloads.any? { |payload| payload['payload']['recipient_url'] == condition}
  end
end