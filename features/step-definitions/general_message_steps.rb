
#########################################
# Given
#########################################

#########################################
# When
#########################################

When(/^I send the (?:email|sms|message)$/) do
  @message.post
  @last_response = @message.response
end

#########################################
# Then
#########################################

Then(/^the response code should be '(.*)'/) do |code|
  raise "expected code: #{code} but was code: #{@last_response.status}" unless @last_response.status.to_s.eql?(code)
end