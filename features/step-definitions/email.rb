#########################################
# Given
#########################################

Given(/^I create an email( with no recipients)?$/) do |recipients|
  @message = client.email_messages.build(body: 'Test',
                                         subject: 'Regression Test email send',
                                         from_email: "#{EmailAdmin.new.from_email}")
  if recipients != " with no recipients"
    @message.recipients.build(email: 'regressiontest2@sink.govdelivery.com')
  end
end

#########################################
# When
#########################################

When(/^I add the macro '(.*)' => '(.*)'$/) do |key,value|
  @message.macros = {key => value}
end

When(/^I set the body to '(.*)'$/) do |body|
  @message.body = body
end

When(/^I add recipient '(.*)$/) do |recipient|
  @message.recipients.build(email: recipient)
end

When(/^I set the subject to '(.*)'$/) do |subject|
  @message.subject = subject
end

When(/^I disable Click tracking$/) do
  @message.click_tracking_enabled = false
end

When(/^I disable Open tracking$/) do
  @message.open_tracking_enabled = false
end
When(/^I set the from email to '(.*)'$/) do |from_email|
  @message.from_email = from_email
end

#########################################
# Then
#########################################

Then(/^(Open|Click) tracking should be disabled$/) do |type|
  raise 'click tracking not disabled'.red unless @message.get.response.body[type.downcase + '_tracking_enabled'] == false
end

Then(/^the message should have macro '(.*)' => '(.*)'$/) do |key, value|
  raise 'no macros found'.red unless @message.get.response.body['macros'] = "{'#{key}'=>'#{value}'}"
end

Then(/^the message should have "(.*)" set to "(.*)"$/) do |field, value|
  actual = @message.body[field]
  raise "expected message field #{field} to have value #{value} but was #{actual}" unless field.eql?(actual)
end

Then(/^I should receive the error "(.*)" in the "(.*)" payload$/) do |message, attribute|
  response = @message.nil? ? @object : @message
  raise "Did not find error: #{message} Messages: #{response.errors.inspect}".red unless !response.errors.nil? && !response.errors[attribute].nil? && response.errors[attribute].join(", ").include?(message)
end

Then(/^the (?:response|message|sms|email) should have no errors$/) do
  raise "Found error: #{@message.errors.inspect}" unless @message.errors.nil?
end

Then(/^the response body should contain valid _links$/) do
  # ap email.response.body
  raise "self not found _links: #{email.response.body['_links']}".red unless @message.get.response.body['_links']['self'].include?('messages/email')
  raise "recipients not found _links:#{email.response.body['_links']}".red unless @message.get.response.body['_links']['recipients'].include?('recipients')
end

Then(/^the response should have a failed recipient$/) do
  pending # Validate that the response has a failed recipient in it.
end

Then(/^the reply to address should be the from email address/) do
  email = @message.get
  raise "reply to address: #{email.reply_to} should equal from addres: #{email.from_email}" unless email.from_email.eql?(email.reply_to)
end

Then(/^the errors to address should default to the account level errors to email$/) do
  pending # Validate that the email is correct
end