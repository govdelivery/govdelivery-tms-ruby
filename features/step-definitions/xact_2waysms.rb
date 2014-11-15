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


#===SUBSCRIBE========================================>


Given(/^I create a subscription keyword and command$/) do
  client = tms_client(:live)
  @keyword = client.keywords.build(:name => keyword_params, :response_text => keyword_params)
  @keyword.post
  @command = @keyword.commands.build(
    :command_type => :dcm_subscribe,
    #do not change the NAME param unless you want to break everything
    :name => "subscribe", 
    :params => dcm_params)
  @command.post
  sleep(2)
end

And(/^I send an SMS to create a subscription on TMS$/) do
  #create connection to XACT
  conn = Faraday.new(:url => "#{xact_url}") do |faraday|
    faraday.request     :url_encoded
    faraday.response    :logger
    faraday.adapter     Faraday.default_adapter
  end

  #create tms/xact twilio request
  payload = {}
  payload['To'] = xact_account(:live)[:sms_phone]
  payload['From'] = sample_subscriber_number
  payload['AccountSid'] = xact_account(:live)[:sms_vendor_username]
  payload['Body'] = subscribe_command
  @resp = conn.post do |req|
    req.url "/twilio_requests.xml"
    req.body = payload
  end

  #encode FROM number as base64 so we're able to retrieve the subscriber record in DCM subscribers API
  @base64 = Base64.encode64(sample_subscriber_number)
  sleep(3)

  #delete tms/xact keyword and command entirely
  @keyword.delete
end

Then(/^a subscription should be created$/) do
  user #dcm credentials
  @request.url = dcm_base64_url + @base64
  @data = HTTPI.get(@request)
  @response = MultiXml.parse(@data.raw_body)
  
  #some output that can be turned on/off if needed to verify things manually
  # ap @response
  # puts @response['subscriber']['phone']

  #verifying if subscriber is present
  if @response['subscriber']['phone'] == sample_subscriber_number[2...12] #about this...DCM strips the +1 from numbers, so we have to also do so to verify if the number exists.
    puts 'Subscriber found, test passed'.green
  else
    fail 'Subscriber not found'.red
  end    

  #delete subscriber so we can reuse the phone number for the next test
  HTTPI.delete(@request)
end



#===STOP========================================>



Given(/^I send an SMS to opt out of receiving TMS messages$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should receive a STOP response$/) do
  pending # express the regexp above with the code you wish you had
end

And(/^a my subscription should be removed$/) do
  pending # express the regexp above with the code you wish you had
end



#===STATIC========================================>



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