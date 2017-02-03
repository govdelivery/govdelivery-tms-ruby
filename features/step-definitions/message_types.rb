def suffix
  @suffix ||= Time.now.to_i.to_s
end

Given(/^a message type exists with code '(.*)'$/) do |code|
  @message_type = @client.message_types.build(code: code)
  @message_type.post # may already exist
end

Given(/^a message type exists with code prefix '(.*)'$/) do |code_prefix|
  step "a message type exists with code '#{code_prefix + suffix}'"
end

Given(/^I create a message type with code prefix '(.*)'$/) do |code_prefix|
  step "a message type exists with code prefix '#{code_prefix}'"
end

Then(/^the message type was created$/) do
  raise "message type creation failed".red unless @message_type.response.status == 201
  @message_type.get # to get the generated label if needed
end

And(/^the message type code starts with '(.*)'$/) do |code_prefix|
  raise "message type code did not start with prefix: #{code_prefix}".red unless @message_type.code == code_prefix + suffix
end

And(/^the message type user visible text is '(.*)'$/) do |visible_text|
  expect(@message_type.label).to start_with(visible_text)
end

And(/^the message type user visible text starts with '(.*)'$/) do |visible_text_prefix|
  step "the message type user visible text is '#{visible_text_prefix + suffix}'"
end

When(/^I update the message type with user visible text '(.*)'$/) do|visible_text_prefix|
  @message_type.label = visible_text_prefix + suffix
  raise "message type was not updated with new user visible text: #{visible_text_prefix + suffix}".red unless @message_type.put
end

Given(/^I list message types in an account without an email vendor$/) do
  @client = TmsClientManager.other_non_admin_client
end

Then(/^the client should not have message_types$/) do
  expect(@client).to_not respond_to(:message_types)
end

When(/^I list message types$/) do
  @message_type_list = @client.message_types.get
end

Then(/^the listing should include a message type with code '(.*)'$/) do |code|
  expect(@message_type_list.collection.select { |mt| mt.code && mt.code == code }).to_not be_empty
end

Then(/^that message type cannot be deleted$/) do
  expect {@message_type.delete}.to raise_error(GovDelivery::TMS::Request::Error)
  raise "message type did not have errors".red if @message_type.errors.try(:empty?)
end

When(/^I delete the message type with code prefix '(.*)'$/) do |prefix|
  @message_type.delete
  raise "message type was not deleted".red unless @message_type.response.status == 204
end

Then(/^the listing should not include a message type with code prefix '(.*)'$/) do |prefix|
  expect(@message_type_list.collection.select { |mt| mt.code && mt.code.start_with?(prefix) }).to be_empty
end
