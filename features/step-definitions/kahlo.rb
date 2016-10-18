Given(/^A kahlo vendor account$/) do
  @vendor = configatron.sms_vendors.kahlo_loopback
  @client = TmsClientManager.from_configatron(@vendor.account.token)
end

When(/^I send an SMS "(.*)" to "(.*)"$/) do |message_body, number|
  @number  = number
  @message = @client.sms_messages.build(body: message_body)
  @message.recipients.build(phone: @number)
  @message.post!
end

When(/^"(.*)" sends an SMS "(.*)" and a timestamp to Kahlo loopback$/) do |sender, body|
  @to    = '+15553665397'
  @from  = sender
  @body  = body + Time.now.to_i.to_s
  payload= {to:   @to,
            from: sender,
            body: body}

  puts "Mocking inbound text ''#{payload}'' to #{configatron.kahlo.url}".yellow
  faraday(configatron.kahlo.url).post do |req|
    req.url '/inbound/loopback'
    req.body = payload
  end
end

Then(/^The status is updated within (.*) seconds$/) do |timeout|
  GovDelivery::Proctor.backoff_check(timeout.to_i.seconds/2, 'all recipient events') do
    begin
      @recipient = @message.recipients.get.collection.first
    rescue GovDelivery::TMS::Request::InProgress => e
      nil
    end
  end

  GovDelivery::Proctor.backoff_check(timeout.to_i.seconds/2, 'all recipient events') do
    puts "message status: #{@recipient.get.status}".yellow
    raise "Unexpected status #{@recipient.status}" unless %w{sending sent}.include?(@recipient.status)
    @recipient.status == 'sent'
  end
end

Then(/^The vendor receives the message and responds with default text$/) do
  expected_response = @client.keywords.get.collection.detect { |k| k.name == 'default' }.response_text
  GovDelivery::Proctor.backoff_check(30, 'all recipient events') do
    begin
      @messages = @client.inbound_sms_messages.get.collection.detect do |m|
        m.to == @to &&
          m.from == @from &&
          m.body == @body &&
          m.response_text == expected_response
      end
    end
  end
end