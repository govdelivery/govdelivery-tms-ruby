
#########################################
# Given
#########################################

#########################################
# When
#########################################

When(/^I send the (?:email|sms|message)$/) do
  @message.post
  @last_response = @message.response
  @message_type = @message.message_type if @message.respond_to?(:message_type)
end

#########################################
# Then
#########################################

Then(/^the response code should be '(.*)'/) do |code|
  raise "expected code: #{code} but was code: #{@last_response.status}" unless @last_response.status.to_s.eql?(code)
end

Then(/^I should receive the error "(.*)" in the "(.*)" payload$/) do |message, attribute|
  response = @message.nil? ? @object : @message
  raise "Did not find error: #{message} Messages: #{response.errors.inspect}".red unless !response.errors.nil? && !response.errors[attribute].nil? && response.errors[attribute].join(", ").include?(message)
end
