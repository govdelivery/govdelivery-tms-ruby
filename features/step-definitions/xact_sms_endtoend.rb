require 'colored'
require 'httpi'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'pry'

BT = {}
BT.store(1, Time.new.to_s + '::' + rand(100_000).to_s)

Given(/^I have a user who can receive SMS messages$/) do
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
  message = client.sms_messages.build(body: "#{BT[1]}")
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
  condition = "#{BT[1]}"

  check_condition = proc do
    payloads = @capi.get(@sms_receiver_uri)
    passed = payloads['payloads'].any? do|payload_info|
      payload_info['body'] == condition
    end
    passed
  end
  begin
    backoff_check(check_condition, 'for the test user to receive the message I sent')
  rescue
    msg = "Message I sent: '#{condition}'\n"
    msg += "Message URL: #{configatron.xact.url + @message.href}\n"
    msg += "Test user callback URL: #{@sms_receiver_full_uri}\n"
    msg += "Payloads the test user received: #{JSON.pretty_generate(payloads)}"
    raise $ERROR_INFO, "#{$ERROR_INFO}\n#{msg}"
  end

  # ap @list
  # if @list["payloads"]["body"] == "#{BT[1]}"
  #   puts 'body found'
  # else
  #   fail
  # end
end


#MBLOX start=====================
#MBLOX ==========================
#MBLOX ==========================


Given(/^I POST a new SMS message to MBLOX$/) do
  client = tms_client(configatron.accounts.sms_endtoend)
  message = client.sms_messages.build(body: "#{BT[1]}")
  message.recipients.build(phone: configatron.test_support.mblox.phone.number)
  puts configatron.test_support.mblox.phone.number
  message.post
  message.recipients.collection.detect(&:errors)
  @message = message
  
end

Given(/^I wait for a response from TMS$/) do
  sleep 10
    @response = @message.get
    i=0
    until @response.response.body["recipient_counts"].present?
      i+=1
      sleep 5
      STDOUT.puts 'waiting for recipient counts to arrive'.yellow
      if i>5
      end  
    end  

    def retryable
      @response = @message.get
      @a = @response.response.body["recipient_counts"]
    end  
end

Then(/^I should receive either a canceled message or a success$/) do
  case 
  when ENV['XACT_ENV'] == :mbloxqc,:mbloxintegration,:mbloxstage
    i=0
    until retryable["canceled"] ==1 || retryable["failed"]  == 1
      STDOUT.puts 'retrieving status'.yellow
      sleep 5
      i+=1
      if i>10
        fail 'Canceled status not found'.red
      end  
    end  
  when ENV['XACT_ENV'] == :mbloxproduction
    i=0
    until retryable["sent"] == 1
      STDOUT.puts 'retrieving status'.yellow
      sleep 5
      i+=1
      if i>10
        fail 'Sent status not found'.red
      end
    end 
  end 
end
