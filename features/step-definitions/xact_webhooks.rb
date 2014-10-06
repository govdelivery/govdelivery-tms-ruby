require 'tms_client'
require 'uri'
require 'net/http'
require 'pry'

$subject = Hash.new #generating a hash value
$subject.store(1, Time.new) #storing the hash value so we can retrieve it later on


Given(/^all message types$/) do
end

Given(/^all event types$/) do
  @event_callback_uris = Hash[event_types.map {|event_type| [event_type,nil]}]
end

Then(/^a callback url exists for each event type$/) do
  @event_callback_uris.each_key do |event_type|
    @event_callback_uris[event_type] = @capi.create_callback_uri(event_type)
  end
end

And(/^a callback url is registered for each event type$/) do
  client = tms_client
  @event_callback_uris.each do |key,value|
    webhook = client.webhooks.build(:url=>@capi.callbacks_domain + value, :event_type=>key)
    webhook.post
    puts "Webhook registered for #{key}: #{value}"
    @webhooks << webhook
  end
end

When(/^I send a message of each type to the magic address of each event state$/) do
  client = tms_client
  @email_message = client.email_messages.build(:body=>'Webhooks Testing',:subject=>"#{$subject[1]}")
  puts 'Sending to the following Email Addresses'
  magic_emails.each do |magic_email|
    @email_message.recipients.build(:email=>magic_email)
    puts "\t#{magic_email}"
  end
  @email_message.post!

  @sms_message = client.sms_messages.build(:body=>'Webhooks Testing')
  puts 'Sending to the following SMS Numbers'
  magic_phone_numbers.each do |magic_number|
    @sms_message.recipients.build(:phone=>magic_number)
    puts "\t#{magic_number}"
  end
  @sms_message.post!

  @voice_message = client.voice_messages.build(:play_url => 'http://www.webhooks-testing.com')
  puts 'Sending to the following Voice Numbers'
  magic_phone_numbers.each do |magic_number|
    @voice_message.recipients.build(:phone=>magic_number)
    puts "\t#{magic_number}"
  end
  @voice_message.post!
end

Then(/^the callback registered for each event state should receive a POST referring to the appropriate message$/) do

  # TODO: backoff_check shouldn't fix our problems
  # TODO: Figure out what to do if recipients list does not get build - is that a test failure?

  message_map = {:email => @email_message, :sms => @sms_message, :voice => @voice_message}
  slept_messages = Hash[message_types.map {|message_type| [message_type,false]}]

  check = Proc.new do
    slept_messages.each do |message_type, got|
      if not got
        begin
          slept_messages[message_type] = message_map[message_type].recipients.get
        rescue TMS::Request::InProgress
          puts "Recipient list for #{message_type} is not ready"
        end
      end
    end
  end

  condition = Proc.new {slept_messages.all?{|event_type, got| got}}
  backoff_check(check, condition, "build recipients list")

  message_map.each do |message_type, message|
    message.recipients.get
    message.recipients.collection.each do |recipient|
      recipient.get
      status = recipient.attributes[:status]
      event_callback_uri = @event_callback_uris[status]
      event_callback = nil

      puts "#{message_type} | Current Status: #{status} | URL: #{recipient.href}"
      puts "Checking webhook registered for #{status}: #{event_callback_uri}"

      check = Proc.new {event_callback = @capi.get(event_callback_uri)}
      condition = Proc.new {event_callback["payload_count"] > 0}
      backoff_check(check, condition, "have at least 1 payload at callback endpoint for #{message_type} #{recipient.href}")

      raise "Callback endpoint for #{message_type} #{recipient.href} should have non-nil payloads\n#{message_type}-#{status} callback endpoint: #{event_callback}" if event_callback["payloads"].nil?

      passed = false
      payloads = []
      condition = xact_url + recipient.href
      event_callback["payloads"].each do |payload_info|
        payloads << @capi.get(payload_info["url"])
        #foo = payloads[-1]["payload"]["recipient_url"]
        #passed = true if payloads[-1]["payload"]["recipient_url"] == condition
        passed = payloads.any?{|payload| payload["payload"]["recipient_url"] == condition}
      end
      raise "#{status} callback endpoint does not have a payload referring to #{condition}\npayloads: #{JSON.pretty_generate(payloads)}" if not passed
    end
  end
end
