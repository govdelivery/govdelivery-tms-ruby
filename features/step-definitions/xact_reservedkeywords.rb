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
    raise "Could not create #{@keyword.name} keyword: #{@keyword.errors}" unless @keyword.post

    if "#{@keyword.errors}".include?('reserved')
      puts 'reserved'
    end  
end




