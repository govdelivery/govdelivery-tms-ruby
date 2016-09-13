Given(/^A kahlo vendor account$/) do |table|
  @event_types = table.raw.map(&:first)
  @vendor      = configatron.sms_vendors.kahlo_loopback
  @client   = TmsClientManager.from_configatron(@vendor.account.token)
end

When(/^I send an SMS "(.*)"$/) do |message_body|
  @number  = "+16125554321"
  @message = @client.sms_messages.build(body: message_body)
  @message.recipients.build(phone: @number)
  @message.post!
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
    raise "Unexpected status #{@recipient.status}" unless @event_types.include?(@recipient.status)
    @recipient.status == 'sent'
  end
end