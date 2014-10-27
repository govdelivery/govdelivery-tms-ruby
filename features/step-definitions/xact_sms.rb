require 'tms_client'
require 'colored'
require 'httpi'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'pry'


##########
# Outline
#
# This should be similar, and simplier, than the Webhooks test
#
# 1. Create a dynamic endpoint for SMSes on the Xact Testing Support app
# 2. Set the SmsUrl/VoiceUrl of the GovD Test User phone number to what was made in step 1
# 3. Send a message to the GovD Test User
# 4. Get payloads from the endpoint made in step 1
# 5. Check whether the message we sent in 3 is in the payloads
# 6. If the test passes, set the GovD Test User phone number SmsUrl/VoiceUrl to nothing, and elete the endpoint made in 1
#
##########

$bt = Hash.new
$bt.store(1, Time.new.to_s + "::" + rand(100000).to_s)

Given (/^I have a user who can receive SMS messages$/)do
  @sms_receiver_uri = @capi.create_callback_uri(:sms, "#{environment.to_s} SMS Receiver")
  #@sms_receiver_uri = '/api/v3/sms/3781'
  @sms_receiver_full_uri = @capi.callbacks_domain + @sms_receiver_uri


  twil = Twilio::REST::Client.new twilio_test_account_creds[:sid], twilio_test_account_creds[:token]
  twil.account.incoming_phone_numbers.get(twilio_test_user_number[:sid]).update(
    :voice_url => @sms_receiver_full_uri,
    :sms_url => @sms_receiver_full_uri
  )
end

Given(/^I POST a new SMS message to TMS$/) do
  next if dev_not_live?

  client = tms_client
  message = client.sms_messages.build(:body=>"#{$bt[1]}")
  message.recipients.build(:phone=>twilio_test_user_number[:phone])
  puts twilio_test_user_number[:phone]
  message.post
  message.recipients.collection.detect{|r| r.errors }
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
    check = Proc.new do
      payloads = @capi.get(@sms_receiver_uri)
      passed = payloads["payloads"].any? {|payload_info|
        payload_info['body'] == condition
      }
    end
    check_condition = Proc.new{passed}
    begin
      backoff_check(check, check_condition, "for the test user to receive the message I sent")
    rescue => e
      msg = "Message I sent: '#{condition}'\n"
      msg += "Message URL: #{xact_url + @message.href}\n"
      msg += "Test user callback URL: #{@sms_receiver_full_uri}\n"
      msg += "Payloads the test user received: #{JSON.pretty_generate(payloads)}"
      raise $!, "#{$!}\n#{msg}"
    end

  # ap @list
  # if @list["payloads"]["body"] == "#{$bt[1]}"
  #   puts 'body found'
  # else
  #   fail
  # end    
end