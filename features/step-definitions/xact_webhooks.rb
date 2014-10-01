require 'tms_client'
require 'uri'
require 'net/http'

$subject = Hash.new #generating a hash value
$subject.store(1, Time.new) #storing the hash value so we can retrieve it later on


Given(/^all message types$/) do
  @message_event_callback_uris = Hash[message_types.map {|message_type| [message_type,nil]}]
end

Given(/^all event types$/) do
  @message_event_callback_uris.each_key do |message_type|
    @message_event_callback_uris[message_type] = Hash[event_types.map {|event_type| [event_type,nil]}]
  end
end

Then(/^a callback url exists for each message type and event type$/) do
    @message_event_callback_uris.each do |message_type, event_callback_uris|
      event_callback_uris.each_key do |event_type|
        event_callback_uris[event_type] = @capi.create_callback_uri(event_type)
      end
    end
end

And(/^a callback url is registered for each message type and event type$/) do
  client = tms_client
  @message_event_callback_uris.each do |message_type, event_callback_uris|
    event_callback_uris.each do |key,value|
      webhook = client.webhooks.build(:url=>@capi.callbacks_domain + value, :event_type=>key)
      webhook.post
      @webhooks << webhook
    end
  end
end

When(/^I send a message of each type to the magic address of each event state$/) do
  client = tms_client
  @email_message = client.email_messages.build(:body=>'Webhooks Testing',:subject=>"#{$subject[1]}")
  magic_emails.each do |magic_email|
    @email_message.recipients.build(:email=>magic_email)
    puts magic_email
  end
  @email_message.post!

  @sms_message = client.sms_messages.build(:body=>'Webhooks Testing')
  magic_phone_numbers.each do |magic_number|
    @sms_message.recipients.build(:phone=>magic_number)
    puts magic_number
  end
  @sms_message.post!

  @voice_message = client.voice_messages.build(:play_url => 'http://www.webhooks-testing.com')
  magic_phone_numbers.each do |magic_number|
    @voice_message.recipients.build(:phone=>magic_number)
    puts magic_number
  end
  @voice_message.post!
end

Then(/^the callback registered for each event state should receive a POST referring to the appropriate message$/) do
  sleep(10)
  # TODO: Sleep shouldn't fix our problems
  # TODO: Figure out what to do if recipients list does not get build - is that a test failure?

  {:email_message => @email_message, :sms_message => @sms_message, :voice_message => @voice_message}.each do |message_type, message|
    message.recipients.get
    recipients.collection.each do |recipient|
      status = recipient.attributes[:status]
      event_callback_uri = @message_event_callback_uris[message_type][status]
      event_callback = @capi.get(event_callback_uri)
      raise "#{status} callback endpoint should have at least 1 payload\n#{status }callback endpoint: #{event_callback}" if event_callback["payload_count"] == 0
      passed = false
      payloads = []
      condition = xact_url + recipient.href
      event_callback["payloads"].each do |payload_info|
        payloads << @capi.get(payload_info["url"])
        foo = payloads[-1]["payload"]["recipient_url"]
        passed = true if payloads[-1]["payload"]["recipient_url"] == condition
      end
    raise "#{status} callback endpoint does not have a payload referring to #{condition}\npayloads: #{payloads}" if not passed
    end
  end
end

Then(/^something$/) do
  puts 'Arby\'s nation.'
end

Given(/^the following "(.*?)":$/) do |arg1, table|
    event_types = event_types.hashes.map {|data| data["event_type"]}
    @event_callback_uris = Hash[event_types.map {|event_type| [event_type,nil]}]
end

Then(/^a callback url exists for each "(.*?)"$/) do |arg1, table|
    @event_callback_uris.each_key do |event_type|
        @event_callback_uris[event_type] = @capi.create_callback_uri(event_type)
    end
end