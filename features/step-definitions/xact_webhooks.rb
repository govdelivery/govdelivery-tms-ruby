require 'uri'
require 'net/http'
require 'pp'

SUBJECT = {} # generating a hash value
SUBJECT.store(1, Time.new) # storing the hash value so we can retrieve it later on

###
# Some data structures used here
#
# @event_callback_uris - Maps event types to callback uris that have been created
# @event_callback_uris = {
#   :sending => 'http://xact-webhook-callbacks.herokuapp.com/api/v2/1000',
#   :blacklisted => 'http://xact-webhook-callbacks.herokuapp.com/api/v2/1001',
#   etc...
# }
#
# @messages - Maps message types to TMS message object
# @messages = {
#   :email => email_message,
#   :sms => sms_message,
#   etc...
# }
#
###

Given(/^all message types$/) do
end

And(/^all event types$/) do
  @event_callback_uris = Hash[event_types.map { |event_type| [event_type, nil] }]
end

Then(/^a callback url exists for each event type$/) do
  @event_callback_uris.each_key do |event_type|
    @event_callback_uris[event_type] = @capi.create_callback_uri(:recipient_status, event_type)
  end
end

And(/^a callback url is registered for each event type$/) do
  client = tms_client(configatron.accounts.webhooks)
  @event_callback_uris.each do |key, value|
    webhook = client.webhooks.build(url: @capi.callbacks_domain + value, event_type: key)
    webhook.post
    puts "Webhook registered for #{key}: #{value}"
    @webhooks << webhook
  end
end

When(/^I send a message of each type to the magic address of each event state$/) do
  client = tms_client(configatron.accounts.webhooks)
  @messages = {}
  @messages[:email] = client.email_messages.build(body: 'Webhooks Testing', subject: "#{SUBJECT[1]}")
  puts 'Sending to the following Email Addresses'
  magic_emails.each do |event_type, magic_email|
    @messages[:email].recipients.build(email: magic_email)
    puts "\t#{event_type}: #{magic_email}"
  end
  @messages[:email].post!

  @messages[:sms] = client.sms_messages.build(body: 'Webhooks Testing')
  puts 'Sending to the following SMS Numbers'
  magic_phone_numbers.each do |event_type, magic_number|
    @messages[:sms].recipients.build(phone: magic_number)
    puts "\t#{event_type}: #{magic_number}"
  end
  @messages[:sms].post!

  @messages[:voice] = client.voice_messages.build(play_url: 'http://www.webhooks-testing.com')
  puts 'Sending to the following Voice Numbers'
  magic_phone_numbers.each do |event_type, magic_number|
    @messages[:voice].recipients.build(phone: magic_number)
    puts "\t#{event_type}: #{magic_number}"
  end
  @messages[:voice].post!
end

Then(/^the callback registered for each event state should receive a POST referring to the appropriate message$/) do
  # TODO: backoff_check shouldn't fix our problems
  # TODO: Figure out what to do if recipients list does not get build - is that a test failure?

  recipients_built = Hash[message_types.map { |message_type| [message_type, false] }]

  condition = proc do
    @messages.each do |message_type, message|
      unless recipients_built[message_type]
        begin
          recipients_built[message_type] = message.recipients.get
        rescue GovDelivery::TMS::Request::InProgress
          STDOUT.puts "Recipient list for #{message_type} is not ready"
        end
      end
    end
    recipients_built.all? { |_message_type, built| built }
  end

  backoff_check(condition, 'build recipients list')

  @messages.each do |message_type, message|
    message.recipients.collection.each do |recipient|
      address = recipient.attributes[:email] ? recipient.attributes[:email] : recipient.attributes[:phone]
      expected_status = status_for_address(magic_addresses(message_type), address)

      condition = proc do
        recipient.get
        expected_status == recipient.attributes[:status].to_sym
      end

      backoff_check(condition, 'arrive at expected status')

      # Given recipient should now be in the status we expected it to be

      event_callback_uri = @event_callback_uris[expected_status]
      event_callback = nil

      puts "#{message_type} | Expected Status: #{expected_status} | Current Status: #{recipient.attributes[:status]} | Message URL: #{recipient.href}"
      puts "\tChecking webhook registered for #{expected_status}: #{event_callback_uri}"

      condition = proc do
        event_callback = @capi.get(event_callback_uri)
        event_callback['payload_count'] >= @messages.count
      end

      backoff_check(condition, "have at least 1 payload per message type at callback endpoint for #{message_type} #{recipient.href}")

      raise "Callback endpoint for #{message_type} #{recipient.href} should have non-nil payloads\n#{message_type}-#{status} callback endpoint: #{event_callback}" if event_callback['payloads'].nil?

      # Callback URI should have received all of the payloads we expected by now

      payloads = []

      check_condition = proc do
        passed = false
        condition = (environment == :integration ? xact_url.sub('int-', 'integration-') : xact_url) + recipient.href
        payloads = []
        event_callback['payloads'].each do |payload_info|
          payloads << @capi.get(payload_info['url'])
          passed = payloads.any? { |payload| payload['payload']['recipient_url'] == condition }
        end
        passed
      end

      begin
        backoff_check(check_condition, 'have all the payloads expected')
      rescue
        webhooks = tms_client(configatron.accounts.webhooks).webhooks
        webhooks.get
        registered_hooks = webhooks.collection.map(&:attributes)
        msg = "'#{expected_status}' callback endpoint does not have a payload referring to '#{condition}'\n"
        msg += "payloads: #{JSON.pretty_generate(payloads)} \n"
        msg += "registered webhooks: #{PP.pp(registered_hooks, '')}"
        raise $ERROR_INFO, "#{$ERROR_INFO}\n#{msg}"
      end
    end
  end
end
