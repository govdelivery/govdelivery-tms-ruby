def suffix
  @suffix ||= Time.now.to_i.to_s
end

Given(/^a message type exists with code '(.*)'$/) do |code|
  @message_type = @client.message_types.build(code: code)
  raise @message_type.errors.inspect unless @message_type.post
end

Given(/^a message type exists with code prefix '(.*)'$/) do |code_prefix|
  step "a message type exists with code '#{code_prefix + suffix}'"
end

Given(/^I create a message type with code prefix '(.*)'$/) do |code_prefix|
  step "a message type exists with code prefix '#{code_prefix}'"
end

Then(/^the message type was created$/) do
  raise "message type creation failed".red unless @message_type.response.status == '201'
end

And(/^the message type code starts with '(.*)'$/) do |code_prefix|
  raise "message type code did not start with prefix: #{code_prefix}".red unless @message_type.code == code_prefix + suffix
end

And(/^the message type user visible text is '(.*)'$/) do |visible_text|
  raise "message type user visible text was not: #{visible_text}".red unless @message_type.user_visible_text == visible_text
end

And(/^the message type user visible text starts with '(.*)'$/) do |visible_text_prefix|
  step "the message type user visible text is '#{visible_text_prefix + suffix}'"
end

When(/^I update the message type with user visible text '(.*)'$/) do|visible_text_prefix|
  @message_type.user_visible_text = visible_text_prefix + suffix
  raise "message type was not updated with new user visible text: #{visible_text_prefix + suffix}".red unless @message_type.post
end

Given(/^I list message types in an account without message types$/) do
  #Todo: admin_client or non_admin_client? We need to use an account without message_types
  @empty_message_type_list = TmsClientManager.non_admin_client.message_types.get
end

Then(/^the listing should be empty$/) do
  raise "this account contains message_types when it shouldn't".red unless @empty_message_type_list.empty?
end

When(/^I list message types$/) do
  @message_type_list = @client.message_types.get
end

Then(/^the listing should include a message type with code '(.*)'$/) do |code|
  raise "message type list did not include a message type with the code #{code}".red unless @message_type_list.any? { |mt| mt.code == code }
end

When(/^I delete the message type with code prefix '(.*)'$/) do |prefix|
  @message_type.delete
  raise "message type was not deleted".red unless @message_type.response.status == '201' || @message_type.get.response.status != '404'
end

Then(/^the listing should not include a message type with code prefix '(.*)'$/) do |prefix|
  raise "message type list did include a message type with the code #{prefix}".red if @message_type_list.any? { |mt| mt.code.start_with? prefix }
end

Then(/^the message type should have an error$/) do
  raise "message type did not have errors".red if @message_type.errors.empty?
end