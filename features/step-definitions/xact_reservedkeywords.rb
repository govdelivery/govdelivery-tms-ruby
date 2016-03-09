require 'colored'
require 'json'
require 'awesome_print'

Given(/^I attempt to create a reserved keyword (.*)$/) do |keyword|
  next if dev_not_live?

  @conf = configatron.accounts.sms_2way_subscribe
  @keyword = TmsClientManager.voice_client.keywords.build(name: keyword)
  raise @keyword.errors.inspect unless @keyword.post
end

Then(/^I should receive an reserved keyword message$/) do
  @output = JSON.parse(@keyword.errors.to_json)

  if @output.to_s.include?('reserved')
    puts 'Keyword is reserved and therefore cannot be created.'.green
  else
    raise 'Keyword was created erroneously.'.red
  end
end
