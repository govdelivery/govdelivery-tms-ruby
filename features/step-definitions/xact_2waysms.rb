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
  next if dev_not_live?

  @conf = configatron.accounts.sms_2way_subscribe
  client = tms_client(@conf)
  @keyword = client.keywords.build(name: "subscribe::#{random_string}", response_text: 'subscribe')
  raise "Could not create #{@keyword.name} keyword: #{@keyword.errors}" unless @keyword.post
  @command = @keyword.commands.build(
    command_type: :dcm_subscribe,
    # do not change the NAME param unless you want to break everything
    name: 'subscribe',
    params: { dcm_account_code: @conf.xact.account.dcm_account_id,
              dcm_topic_codes: @conf.xact.account.dcm_topic_codes })
  raise "Could not create #{@command.name} command: #{@command.errors}" unless @command.post

  sleep(2)
end

And(/^I send an SMS to create a subscription on TMS$/) do
  next if dev_not_live?

  # create connection to XACT
  conn = Faraday.new(url: @conf.xact.url) do |faraday|
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end

  # create tms/xact twilio request
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = sample_subscriber_number
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name}"
  puts "Mocking text '#{payload['Body']}' to #{payload['To']}"
  @payload = payload
  @resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end

  if @resp.status == 500
    raise "Error mocking text, received HTTP 500: #{@resp.body}"
  end

  # encode FROM number as base64 so we're able to retrieve the subscriber record in DCM subscribers API
  @base64 = Base64.encode64(sample_subscriber_number)
  sleep(10)
end

Then(/^a subscription should be created$/) do
  next if dev_not_live?

  user # dcm credentials
  @request.url = dcm_base64_url + @base64
  @data = HTTPI.get(@request)
  puts @request.url
  @response = MultiXml.parse(@data.raw_body)
  # some output that can be turned on/off if needed to verify things manually
  ap @response
  puts @response['subscriber']['phone']

  # verifying if subscriber is present
  begin
    if @response['subscriber']['phone'] == sample_subscriber_number[2...12] # about this...DCM strips the +1 from numbers, so we have to also do so to verify if the number exists.
      puts 'Subscriber found, test passed'.green
    else
      raise 'Subscriber not found'.red
    end
  rescue NoMethodError
    raise JSON.pretty_generate(@response)
  end

  # delete subscriber so we can reuse the phone number for the next test
  HTTPI.delete(@request)
end

#===STOP========================================>

Given(/^I am subscribed to receive TMS messages$/) do
  next if dev_not_live?

  # subscribe first
  @conf = configatron.accounts.sms_2way_stop
  conn = Faraday.new(url: @conf.xact.url) do |faraday|
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end

  # create tms/xact twilio request
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = twilio_xact_test_number_2
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} subscribe"
  puts "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end

  if resp.status == 500
    raise "Error mocking text, received HTTP 500: #{resp.body}"
  end

  # sleep to give subscription time to create in DCM
  sleep(10)
end

Given(/^I create a stop keyword and command$/) do
  next if dev_not_live?

  client = tms_client(@conf)
  @keyword = client.keywords.build(name: "stop::#{random_string}", response_text: 'stop')
  raise "Could not create #{@keyword.name} keyword: #{@keyword.errors}" unless @keyword.post
  @command = @keyword.commands.build(
    command_type: :dcm_unsubscribe,
    # do not change the NAME param unless you want to break everything
    name: 'unsubscribe',
    params: { dcm_account_codes: @conf.xact.account.dcm_account_id })
  raise "Could not create #{@command.name} command: #{@command.errors}" unless @command.post

  sleep(2)
end

When(/^I send an SMS to opt out of receiving TMS messages$/) do
  next if dev_not_live?

  # begin stop request
  conn = Faraday.new(url: @conf.xact.url) do |faraday|
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end

  # create tms/xact twilio request
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = twilio_xact_test_number_2
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name}"
  puts "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  @resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end

  if @resp.status == 500
    raise "Error mocking text, received HTTP 500: #{@resp.body}"
  end
end

Then(/^I should receive a STOP response$/) do
  next if dev_not_live?

  resp_xml = Hash.from_xml @resp.body
  if resp_xml['Response']['Sms'] != 'stop'
    ap @resp
    raise 'Did not receive STOP response'
  end
end

And(/^my subscription should be removed$/) do
  next if dev_not_live?

  # encode FROM number as base64 so we're able to retrieve the subscriber record in DCM subscribers API
  @base64 = Base64.encode64(twilio_xact_test_number_2)

  sleep(60)

  # check to see if subscription was removed
  user # dcm credentials
  @request.url = dcm_base64_url + @base64
  @data = HTTPI.get(@request)
  puts @request.url
  @response = MultiXml.parse(@data.raw_body)

  ap @response
  # some output that can be turned on/off if needed to verify things manually
  # puts @response['subscriber']['phone']

  # verifying if subscriber is present
  if @response['errors'] && @response['errors']['error'] == 'Subscriber not found'
    puts 'Subscriber not found'.green
  else
    raise 'Subscriber found - Expected subscriber to not exist'.red
  end
end

#===STATIC========================================>

Given(/^A keyword with static content is configured for an TMS account$/) do
  @conf = configatron.accounts.sms_2way_static
  client = tms_client(@conf)
  @keyword = client.keywords.build(name: random_string, response_text: random_string)
  @keyword.post
end

Given(/^I send that keyword as an SMS to TMS$/) do
  conn = Faraday.new(url: "#{@conf.xact.url}") do |faraday|
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = '+15555555555'
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name}"
  puts "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  @resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end
end

Then(/^I should receive static content$/) do
  twiml = Hash.from_xml @resp.body
  received_content = twiml['Response']['Sms']
  expected_content = @keyword.response_text
  raise "Received incorrect content: '#{received_content}', expected: '#{expected_content}', keyword url: #{@conf.xact.url}#{@keyword.href}" if received_content != expected_content
end

#===Common-2-Way-Real-Time-Steps================>

def agency_command_params(agency)
  url = case agency.downcase
        when 'bart'
          'https://xact-services-stage.herokuapp.com/bart'
        when 'acetrain'
          'https://xact-services-stage.herokuapp.com/acetrain'
        when 'cdc'
          'https://xact-services-stage.herokuapp.com/knowit'
        end
  {
    url:           url,
    http_method:   'get',
    strip_keyword: true
  }
end

def agency_test(agency, check)
  case agency.downcase
  when 'bart', 'acetrain', 'cdc'
    expected_condition = 200
    { condition: proc do
      actions = check.call
      actions.any? do |action|
        action.status == expected_condition &&
          !action.response_body.blank? &&
          !action.response_body.include?('We are sorry, but the message you sent is not valid.')
      end if actions
    end,
      msg: "Expected to receive HTTP Status #{expected_condition},to receive non-blank response_text, and to not receive an error message"
    }
  end
end

Given(/^I have an XACT account for (.+)$/) do |agency|
  @conf = configatron.accounts["sms_2way_#{agency.downcase}"]
  @client = tms_client(@conf)
end

Given(/^I register the keyword (.+)$/) do |agency|
  # Register a unique keyword each time, so that test failures can save the keyword for review without concern for future test keyword collisions
  @agency_keyword = "#{agency.downcase}#{random_string}"
  @keyword = @client.keywords.build(name: @agency_keyword)
  raise "Could not create #{@agency_keyword} keyword: #{@keyword.errors}" unless @keyword.post
end

Given(/^I register the (.+) forward command$/) do |agency|
  @command = @keyword.commands.build(
    name: "#{agency} Forwarding",
    params: agency_command_params(agency),
    command_type: :forward
  )
  raise "Could not create Forwarding command: #{@command.errors}" unless @command.post
end

When(/^I text '(.+)' to the (.+) account$/) do |message, _agency|
  # Don't actually care about the keyword that is passed to this test
  message = message.split[1..-1].join(' ')

  conn = Faraday.new(url: "#{@conf.xact.url}") do |faraday|
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = '+15005550006'
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name} #{message}"
  puts "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  @resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end
end

Then(/^I should receive (.+) content as a response$/) do |agency_name|
  # TODO Can we find the actual message that XACT sent back?

  check = proc do
    # The API does not provide the command_actions relation on a command if there are no command actions
    # Thus, we need to be ready to catch a NoMethodError in case a command action has not been created
    # by the time the test wants to check for one.
    @command.get
    @command.try(:command_actions).try(:get)
    @command.try(:command_actions).try(:collection)
  end

  test = agency_test(agency_name, check)

  begin
    backoff_check(test[:condition], "for #{agency_name} to send an acceptable response")
  rescue
    msg = test[:msg]
    msg += "\nCommand URL: #{@command.href}"
    raise $ERROR_INFO, "#{$ERROR_INFO}\n#{msg}"
  end
end
