Given(/^I have a user who can receive SMS messages$/) do
  @event_uri             = @capi.create_callback_uri(:sms, "#{environment} SMS Receiver")
  @sms_receiver_full_uri = @capi.callback_domain + @event_uri

  twil = TwilioClientManager.default_client

  twil.account.incoming_phone_numbers.get(configatron.test_support.twilio.phone.sid).update(
    voice_url: @sms_receiver_full_uri,
    sms_url:   @sms_receiver_full_uri
  )
end

Given(/^I have an SMS template$/) do
  next if dev_not_live?

  client            = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend.xact.token)
  @expected_message = message_body_identifier
  @template         = client.sms_templates.build(body: @expected_message, uuid: "new-sms-template-#{Time.now.to_i}")
  @template.post!
  @template
end

# blank message throws
# Couldn't POST GovDelivery::TMS::SmsMessage to /messages/sms:
# body can't be blank (GovDelivery::TMS::Errors::InvalidPost)
Given(/^I POST a new SMS message to TMS$/) do
  next if dev_not_live?

  client = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend.xact.token)
  @expected_message = message_body_identifier
  message           = client.sms_messages.build(body: @expected_message)
  message.recipients.build(phone: configatron.test_support.twilio.phone.number)
  log.info configatron.test_support.twilio.phone.number
  message.post!
  @message = message
end

Given(/^I POST a new blank SMS message to TMS$/) do
  next if dev_not_live?

  client = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend.xact.token)
  @expected_message = message_body_identifier
  message           = client.sms_messages.build
  message.recipients.build(phone: configatron.test_support.twilio.phone.number)
  log.info configatron.test_support.twilio.phone.number
  message.post!
  @message = message
end

When(/^I wait for a response from twilio$/) do
  next if dev_not_live?
end

Then(/^I should be able to identify my unique message is among all SMS messages$/) do
  next if dev_not_live?
  payloads        = []

  begin
    GovDelivery::Proctor.backoff_check(10.minutes, 'for the test user to receive the message I sent') do
      payloads = @capi.get(@event_uri)
      payloads['payloads'].any? do |payload_info|
        payload_info['body'] == @expected_message
      end
    end
  rescue
    msg = "Message I sent: '#{condition}'\n"
    msg += "Message URL: #{configatron.xact.url + @message.href}\n"
    msg += "Test user callback URL: #{@sms_receiver_full_uri}\n"
    msg += "Payloads the test user received: #{JSON.pretty_generate(payloads)}"
    raise $ERROR_INFO, "#{$ERROR_INFO}\n#{msg}"
  end
end

# MBLOX start=====================
# MBLOX ==========================
# MBLOX ==========================

Given(/^I POST a new SMS message to MBLOX$/) do
  client            = TmsClientManager.from_configatron(configatron.accounts.sms_endtoend.xact.token)
  @expected_message = message_body_identifier
  message           = client.sms_messages.build(body: @expected_message)
  message.recipients.build(phone: configatron.test_support.mblox.phone.number)
  log.info configatron.test_support.mblox.phone.number
  message.post!
  @message = message
end

Then(/^I should receive either a canceled message or a success$/) do
  GovDelivery::Proctor.backoff_check(5.minutes, 'checking for completed recipient status') do
    case ENV['XACT_ENV']
    when 'mbloxqc', 'mbloxintegration', 'mbloxstage'
      response_body = @message.get.response.body
      log.info "got body: #{response_body}"
      response_body["recipient_counts"] &&
        (response_body["recipient_counts"]["canceled"] == 1 ||
          response_body["recipient_counts"]["failed"] == 1
        )
    when 'mbloxproduction'
      response_body = @message.get.response.body
      log.info "got body: #{response_body}"
      response_body["recipient_counts"] && response_body["recipient_counts"]["sent"] == 1
    end
  end
end

Given(/^I create a new sms template with "(.*)" uuid$/) do |uuid|
  @template = TmsClientManager.non_admin_client.sms_templates.build(body: message_body_identifier, uuid: uuid)
  @template.post!
end
