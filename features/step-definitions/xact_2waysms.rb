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
  user
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


#===BART========================================>

Given (/^I have an XACT account for BART$/) do
  @client = tms_client(:bart)
end

Given (/^I register the keyword BART$/) do
  # Register a unique keyword each time, so that test failures can save the keyword for review without concern for future test keyword collisions
  @bart_keyword = "BART#{random_string}"
  @keyword = @client.keywords.build(:name => @bart_keyword)
  raise "Could not create #{@bart_keyword} keyword: #{@keyword.errors}" unless @keyword.post
end

Given (/^I register the BART forward command$/) do
  @command = @keyword.commands.build(
    :name => "BART Forwarding",
    :params => {
      :url => 'http://ws.sfbart.org/sms/request.aspx',
      :http_method => 'get',
      :from_param_name => 'user',
      :sms_body_param_name => 'req',
      :strip_keyword => true
    },
    :command_type => :forward
  )
  raise "Could not create Forwarding command: #{@command.errors}" unless @command.post
end

When (/^I text 'BART 12th' to the BART account$/) do
  conn = Faraday.new(:url => "#{xact_url}") do |faraday|
    faraday.request     :url_encoded
    faraday.response    :logger
    faraday.adapter     Faraday.default_adapter
  end
  payload = {}
  payload['To'] = xact_account(:bart)[:sms_phone]
  payload['From'] = '+15005550006'
  payload['AccountSid'] = xact_account(:bart)[:sms_vendor_username]
  payload['Body'] = "#{@bart_keyword} 12th"
  @resp = conn.post do |req|
    req.url "/twilio_requests.xml"
    req.body = payload
  end
end

Then (/^I should receive BART content as a response$/) do
  # TODO Can we find the actual message that XACT sent back?
  passed = false
  expected_status = 200

  check = Proc.new do
    # The API does not provide the command_actions relation on a command if there are no command actions
    # Thus, we need to be ready to catch a NoMethodError in case a command action has not been created
    # by the time the test wants to check for one.
    begin
      @command.get
      @command.command_actions.get
      @actions = @command.command_actions.collection
    rescue NoMethodError => e
      next
    end
    passed = @actions.any? do |action|
      action.status == expected_status && !action.response_body.blank?
    end
  end
  check_condition = Proc.new{passed}
  begin
    backoff_check(check, check_condition, "for BART to send an acceptable response")
  rescue => e
    msg = "Expected to receive HTTP Status #{expected_status} and expected to receive non-blank response_text"
    msg += "Command URL: #{@command.href}"
    raise $!, "#{$!}\n#{msg}"
  end
end
