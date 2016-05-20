#########################################
# Given
#########################################

Given(/^I build an email template(?: with uuid '(.*)?')?$/) do |uuid|
  @template = @client.email_templates.build(body: '<p><a href="http://www.cnn.com">Test</a>',
                                            subject: "XACT-545-1 Email Test for link parameters #{Time.new}",
                                            macros: {"closing" => "yo"},
                                            uuid: uuid || nil,
                                            open_tracking_enabled: false,
                                            click_tracking_enabled: false)
end

Given(/^an email template exists$/) do
  step 'I build an email template'
  step 'I save the email template'
end

#########################################
# When
#########################################

When(/^I save the email template$/) do
  @template.post
  @last_response = @template.response
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

When(/^I send an EMAIL message specifying just that template and a recipient$/) do
  @message = @client.email_messages.build
  @message.links[:email_template] = @template.uuid
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
  raise @message.errors.to_s unless @message.get
  [:body, :subject, :macros, :open_tracking_enabled, :click_tracking_enabled].each do |attr|
    if @message.send(attr) != @template.send(attr)
      raise "Template value for #{attr} not used in message: expected #{@template.send(attr)}, found #{@message.send(attr)}"
    end
  end
end