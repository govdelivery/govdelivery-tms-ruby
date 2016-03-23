#####################################################
# Given
#####################################################

Given(/^A voice message resource with recipients$/) do
  step 'I create a new voice message'
  step 'I add a recipient to the voice message'
end

#####################################################
# When
#####################################################

When(/^I create a new voice message$/) do
  @message = TmsClientManager.non_admin_client.voice_messages.build(play_url: configatron.voice.play_urls.sample)
end

When(/^I add a recipient to the voice message$/) do
  @message.recipients.build(phone: configatron.voice.recipient.number)
end

When(/^I POST it/) do
  raise @message.errors.inspect unless @message.post
  log.ap @message.errors if @message.errors
end

When(/^I add another phone number to the message$/) do
  @message.recipients.build(phone: configatron.voice.recipient.secondary_number)
end

#####################################################
# Then
#####################################################

Then(/^Twilio should have an active call$/) do
  @client = TwilioClientManager.default_client
  calls = []
  GovDelivery::Proctor.backoff_check(10.minutes, "have a ringing call") do
    calls = @client.account.calls.list(start_time: Date.today,
                                       status:     'ringing',
                                       from:       '(651) 504-3057')

    !calls.empty?
  end
  @call = calls.first.uri
end

Then(/^Twilio should complete the call$/) do


  # call to twilio callsid json
  conn = faraday("https://api.twilio.com/#{@call}")
  conn.headers['Content-Type'] = 'application/json'
  conn.basic_auth(configatron.test_support.twilio.account.sid , configatron.test_support.twilio.account.token)

  GovDelivery::Proctor.backoff_check(10.minutes, "call") do
    JSON.parse(conn.get.body)['status'] == 'completed'
  end
end

Then(/^I should see a list of messages with appropriate attributes$/) do
  messages = TmsClientManager.non_admin_client.voice_messages.get.collection
  sleep(2)

  messages.each do |message|
    %w{play_url status created_at}.each do |attr|
      raise "#{attr} was not found in message #{message.attributes}".red unless message.attributes[attr.to_sym]
    end
  end
end

Then(/^I should be able to verify details of the message$/) do
  sleep(10)

  @message.get
  body = @message.response.body

  unless (voice_links = body['_links'])
    raise "No _links relation found in #{body}".red
  end

  %w{recipients failed self sent human machine busy no_answer could_not_connect}.each do |rel|
    if voice_links.include?(rel)
      log.info "#{rel} relation found".green
    else
      raise "#{rel} relation was not found in #{body}".red
    end
  end

  unless (recipient_counts = body['recipient_counts'])
    raise "No recipient_counts found in #{body}".red
  end

  %w{total new sending inconclusive blacklisted canceled sent failed}.each do |recipient_count|
    if recipient_counts.has_key?(recipient_count)
      log.info "#{recipient_count} found".green
    else
      raise 'Total was not found'.red
    end
  end
end

