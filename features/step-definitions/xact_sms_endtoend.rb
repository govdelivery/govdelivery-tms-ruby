require 'colored'
require 'httpi'
require 'json'
require 'awesome_print'
require 'twilio-ruby'

Given(/^I have a user who can receive SMS messages$/) do
  @sms_receiver_uri      = @capi.create_callback_uri(:sms, "#{environment} SMS Receiver")
  @sms_receiver_full_uri = @capi.callback_domain + @sms_receiver_uri

  twil = TwilioClientManager.default_client

  twil.account.incoming_phone_numbers.get(configatron.test_support.twilio.phone.sid).update(
    voice_url: @sms_receiver_full_uri,
    sms_url:   @sms_receiver_full_uri
  )
end

Given(/^I have an SMS template$/) do
  next if dev_not_live?

  client            = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend)
  @expected_message = message_body_identifier
  @template         = client.sms_templates.build(body: @expected_message, uuid: "new-sms-template-#{Time.now.to_i.to_s}")
  @template.post!
  @template
end


Given(/^I POST a new SMS message to TMS$/) do
  next if dev_not_live?

  client = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend)
  @expected_message = message_body_identifier
  message           = client.sms_messages.build(body: @expected_message)
  message.recipients.build(phone: configatron.test_support.twilio.phone.number)
  puts configatron.test_support.twilio.phone.number
  message.post!
  @message = message
end

Given(/^I POST a new blank SMS message to TMS$/) do
  next if dev_not_live?

  client = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend)
  @expected_message = message_body_identifier
  message           = client.sms_messages.build
  message.recipients.build(phone: configatron.test_support.twilio.phone.number)
  puts configatron.test_support.twilio.phone.number
  message.post!
  @message = message
end


When(/^I wait for a response from twilio$/) do
  next if dev_not_live?
end

Then(/^I should be able to identify my unique message is among all SMS messages$/) do
  next if dev_not_live?
  payloads        = []
  check_condition = proc do
    payloads = @capi.get(@sms_receiver_uri)
    passed   = payloads['payloads'].any? do |payload_info|
      payload_info['body'] == @expected_message
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
  client            = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend)
  @expected_message = message_body_identifier
  message           = client.sms_messages.build(body: @expected_message)
  message.recipients.build(phone: configatron.test_support.mblox.phone.number)
  puts configatron.test_support.mblox.phone.number
  message.post!
  @message = message

end

Then(/^I should receive either a canceled message or a success$/) do
  check_condition = case ENV['XACT_ENV']
                      when 'mbloxqc', 'mbloxintegration', 'mbloxstage'
                        proc do
                          response_body = @message.get.response.body
                          STDOUT.puts "got body: #{response_body}"
                          response_body["recipient_counts"] &&
                            (response_body["recipient_counts"]["canceled"] == 1||
                              response_body["recipient_counts"]["failed"] == 1
                            )
                        end
                      when 'mbloxproduction'
                        proc do
                          response_body = @message.get.response.body
                          STDOUT.puts "got body: #{response_body}"
                          response_body["recipient_counts"] && response_body["recipient_counts"]["sent"] == 1
                        end
                    end
  backoff_check(check_condition, "checking for completed recipient status")
end

Given(/^I create a new sms template with "(.*)" uuid$/) do |uuid|
  @template = TmsClientManager.voice_client.sms_templates.build(body: message_body_identifier, uuid: uuid)
  @template.post!
end
