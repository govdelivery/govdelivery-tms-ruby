#########################################
# Given
#########################################

Given(/^I build an email template(?: with uuid '(.*)?')?$/) do |uuid|
  @template = @client.email_templates.build(body: '<p><a href="http://www.cnn.com">Test</a>',
                                            link_tracking_parameters: "from=me&one=two",
                                            subject: "XACT-545-1 Email Test for link parameters #{Time.new}",
                                            macros: {"closing" => "yo"},
                                            uuid: uuid || nil,
                                            open_tracking_enabled: false,
                                            click_tracking_enabled: false)
end

Given(/^an email template exists(?: with a message_type_code '(.*)')?$/) do |code|
  step 'I build an email template'
  step "I set the message_type_code on the template to '#{code}'" if code
  step 'I save the email template'
end

#########################################
# When
#########################################

When(/^I save the email template$/) do
  @template.post
  @last_response = @template.response
  @message_type = @template.message_type if @template.respond_to?(:message_type)
end

When(/^I update the email template$/) do
  @template.put
  @last_response = @template.response
end

When(/^I delete the email template$/) do
  @template.delete
  @last_response = @template.response
end

When(/^I update the body to '(.*)'$/) do |body|
  @template.body = body
end

When(/^I update the uuid to '(.*)'$/) do |uuid|
  @template.uuid = uuid
end

When(/^I get the email template$/) do
  @template.get
  @last_response = @template.response
end

When(/^I send an email with everything specified and a template$/) do
  step "I create an email"
  step "I add the macro 'city' => 'St Paul'"
  step "I disable Click tracking"
  step "I disable Open tracking"
  step "I set the body to 'specified my body'"
  @message.links[:email_template] = @template.uuid
  @message.recipients.build(email: "happy@golucky.com")
  @specified_values = @message.clone
  step "I send the email"
end

When(/^I send an EMAIL message specifying just that template and a recipient(?: and message_type_code '(.*)')?$/) do |code|
  @message = @client.email_messages.build
  @message.links[:email_template] = @template.uuid
  step "I set the message_type_code to '#{code}'" if code
  @message.recipients.build(email: 'happy@golucky.com')
end

#########################################
# Then
#########################################

Then(/^the template should have body '(.*)'$/) do |body|
  @template.get
  @last_response = @template.response
  raise "template should have updated body: #{body}, but was: #{@template.body}" unless @template.body.eql?(body)
end

Then(/^the template should no longer exist$/) do
  temp = @client.email_templates.get.collection.select { |e| e.uuid.eql?(@template.uuid) }
  raise "should have raised a 404 not found exception on get template: #{@template}" unless temp.empty?
end

Then(/^the uuid should (not)? be '(.*)'$/) do |invert, uuid|
  @template.get
  if ('not'.eql?(invert))
    raise "uuid should not be #{uuid} but was" if uuid.eql?(@template.uuid)
  else
    raise "uuid should be #{uuid} but was #{@template.uuid}" unless uuid.eql?(@template.uuid)
  end
end

Then(/^the message should have the attributes from the template$/) do
  raise @message.error.to_s unless @message.post
  GovDelivery::Proctor.backoff_check(1.minutes, " for message to get queued") do
    begin
      @message.get
      @message.status != "new"
    rescue GovDelivery::TMS::Request::InProgress
      false
    end
  end
  if @message.body == @template.body
    raise "Message body has not been modified according to template: found #{@message.body}"
  end
  [:subject, :macros, :open_tracking_enabled, :click_tracking_enabled].each do |attr|
    if @message.send(attr) != @template.send(attr)
      raise "Template value for #{attr} not used in message: expected #{@template.send(attr)}, found #{@message.send(attr)}"
    end
  end
end

And(/^I (?:set|update) the message_type_code on the template to '(.*)'$/) do |message_type_code|
  @template.message_type_code = message_type_code
end

And(/^I remove the message_type_code from the template$/) do
  @template.message_type_code = nil
end

And(/^the template response should contain a message_type_code with value '(.*)'$/) do |message_type_code|
  code = @template.get.response.body['message_type_code']
  raise "message type code field not found".red if code.nil?
  raise "message type code not found in #{code}".red unless code == message_type_code
end

And(/^the template response should contain a link to the message type$/) do
  expect(@template.message_type).to be_a(GovDelivery::TMS::MessageType)
end

And(/^the response should not contain a message_type_code$/) do
  expect(@template.message_type_code).to be_nil
end

And(/^the response should not contain a link to the message type$/) do
  expect(@template.message_type).to be_nil
end
