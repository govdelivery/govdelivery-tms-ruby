require 'tms_client'
require 'colored'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'httpi'
require 'pry'
require 'faraday'
require 'base64'
require 'multi_xml'


Given(/^I attempt to create a reserved keyword (.*)$/) do |keyword|
  next if dev_not_live?

  @conf = configatron.accounts.sms_2way_subscribe
  client = tms_client(@conf)
  @keyword = client.keywords.build(:name => keyword)
  keyword = @transformed_keyword
    STDOUT.puts @keyword.errors unless @keyword.post    
end

Then(/^I should receive an reserved keyword message$/) do
  @output = JSON.parse(@keyword.errors.to_json)

    if @output.to_s.include?('reserved')
      puts 'Keyword is reserved and therefore cannot be created.'.green
    else
      raise 'Keyword was created erroneously.'.red
    end
end
