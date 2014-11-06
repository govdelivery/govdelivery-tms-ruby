require 'tms_client'
require 'colored'
require 'httpi'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'tms_client'

$bt = Hash.new
$bt.store(1, Time.new.to_s + "::" + rand(100000).to_s)


Given(/^I send an SMS to create a subscription on TMS$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should receive a SUBSCRIBE response$/) do
  pending # express the regexp above with the code you wish you had
end

And(/^a subscription should be created$/) do
  pending # express the regexp above with the code you wish you had
end



Given(/^I send an SMS to opt out of receiving TMS messages$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should receive a STOP response$/) do
  pending # express the regexp above with the code you wish you had
end

And(/^a my subscription should be removed$/) do
  pending # express the regexp above with the code you wish you had
end


Given (/^A keyword with static content is configured for an TMS account$/) do
  client = tms_client(:loopback)
  @keyword = client.keywords.build(:name => random_string, :response_text => random_string)
  @keyword.post
end

Given (/^I send that keyword as an SMS to TMS$/) do
  conn = Faraday.new(:url => "#{xact_url}") do |faraday|
    faraday.request     :url_encoded
    faraday.response    :logger
    faraday.adapter     Faraday.default_adapter
  end
  payload = {}
  payload['To'] = xact_account(:loopback)[:sms_phone]
  payload['From'] = '+15555555555'
  payload['AccountSid'] = xact_account(:loopback)[:sms_vendor_username]
  payload['Body'] = @keyword.name
  @resp = conn.post do |req|
    req.url "/twilio_requests.xml"
    req.body = payload
  end
end

Then (/^I should receive static content$/) do
  twiml = Hash.from_xml @resp.body
  received_content = twiml['Response']['Sms']
  expected_content = @keyword.response_text
  raise "Received incorrect content: '#{received_content}', expected: '#{expected_content}', keyword url: #{xact_url}#{@keyword.href}" if received_content != expected_content
end