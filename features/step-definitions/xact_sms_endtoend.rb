require 'colored'
require 'httpi'
require 'json'
require 'awesome_print'
require 'twilio-ruby'

$bt = {}
$bt.store(1, Time.new.to_s + '::' + rand(100_000).to_s)

Given (/^I have a user who can receive SMS messages$/)do
  @sms_receiver_uri = @capi.create_callback_uri(:sms, "#{environment} SMS Receiver")
  @sms_receiver_full_uri = @capi.callbacks_domain + @sms_receiver_uri

  twil = Twilio::REST::Client.new(
    configatron.test_support.twilio.account.sid,
    configatron.test_support.twilio.account.token
  )
  twil.account.incoming_phone_numbers.get(configatron.test_support.twilio.phone.sid).update(
    voice_url: @sms_receiver_full_uri,
    sms_url: @sms_receiver_full_uri
  )
end

Given(/^I POST a new SMS message to TMS$/) do
  next if dev_not_live?

  client = tms_client(configatron.accounts.sms_endtoend)
  message = client.sms_messages.build(body: "#{$bt[1]}")
  message.recipients.build(phone: configatron.test_support.twilio.phone.number)
  puts configatron.test_support.twilio.phone.number
  message.post
  message.recipients.collection.detect(&:errors)
  @message = message
end

And(/^I wait for a response from twilio$/) do
  next if dev_not_live?
end

Then(/^I should be able to identify my unique message is among all SMS messages$/) do
  next if dev_not_live?

  passed = false
  payloads = []
  condition = "#{$bt[1]}"

  check_condition = proc do
    payloads = @capi.get(@sms_receiver_uri)
    passed = payloads['payloads'].any? do|payload_info|
      payload_info['body'] == condition
    end
    passed
  end
  begin
    backoff_check(check_condition, 'for the test user to receive the message I sent')
  rescue => e
    msg = "Message I sent: '#{condition}'\n"
    msg += "Message URL: #{configatron.xact.url + @message.href}\n"
    msg += "Test user callback URL: #{@sms_receiver_full_uri}\n"
    msg += "Payloads the test user received: #{JSON.pretty_generate(payloads)}"
    raise $ERROR_INFO, "#{$ERROR_INFO}\n#{msg}"
  end

  # ap @list
  # if @list["payloads"]["body"] == "#{$bt[1]}"
  #   puts 'body found'
  # else
  #   fail
  # end
end
