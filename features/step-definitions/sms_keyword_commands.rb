#===SUBSCRIBE========================================>

Given(/^I create a subscription keyword and command$/) do
  pending "Not implemented for development"  if dev_not_live?

  @conf = configatron.accounts.sms_keyword_commands_subscribe
  client = TmsClientManager.from_configatron(@conf)
  @keyword = client.keywords.build(name: "subscribe::#{random_string}", response_text: 'subscribe')
  raise "Could not create #{@keyword.name} keyword: #{@keyword.errors}" unless @keyword.post
  @command = @keyword.commands.build(
    command_type: :dcm_subscribe,
    # do not change the NAME param unless you want to break everything
    name: 'subscribe',
    params: {dcm_account_code: @conf.xact.account.dcm_account_id,
             dcm_topic_codes: @conf.xact.account.dcm_topic_codes})
  raise "Could not create #{@command.name} command: #{@command.errors}" unless @command.post
end

When(/^I send an SMS to create a subscription on TMS$/) do
  pending "Not implemented for development"  if dev_not_live?

  # create connection to XACT
  conn = faraday(@conf.xact.url)

  # create tms/xact twilio request
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = sample_subscriber_number
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name}"
  log.info "Mocking text '#{payload['Body']}' to #{payload['To']}"
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
end

Then(/^a subscription should be created$/) do
  pending "Not implemented for development" if dev_not_live?

  conn = faraday(configatron.evolution.api_url + @base64)
  conn.headers['Content-Type'] = 'application/xml'
  conn.basic_auth(configatron.evolution.account.email_address, configatron.evolution.account.password)

  begin
    GovDelivery::Proctor.backoff_check(3.minutes, 'should create subscriber') do
      @response = MultiXml.parse(conn.get.body)
      # some output that can be turned on/off if needed to verify things manually
      log.ap @response

      # DCM strips the +1 from numbers, so we have to also do so to verify if the number exists.
      @response && @response['subscriber'] && @response['subscriber']['phone'] == sample_subscriber_number[2...12]
    end
  ensure
    # delete subscriber so we can reuse the phone number for the next test
    conn.delete
  end
end

#===STOP========================================>

Given(/^I am subscribed to receive TMS messages$/) do
  pending "Not implemented for development"  if dev_not_live?

  # subscribe first
  @conf = configatron.accounts.sms_keyword_commands_stop
  conn = faraday(@conf.xact.url)

  # create tms/xact twilio request
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = twilio_xact_test_number_2
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} subscribe"
  log.info "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end

  if resp.status == 500
    raise "Error mocking text, received HTTP 500: #{resp.body}"
  end

  sleep 10
end

Given(/^I create a stop keyword and command$/) do
  pending "Not implemented for development"  if dev_not_live?

  client = TmsClientManager.from_configatron(@conf)
  @keyword = client.keywords.build(name: "stop::#{random_string}", response_text: 'stop')
  raise "Could not create #{@keyword.name} keyword: #{@keyword.errors}" unless @keyword.post
  @command = @keyword.commands.build(
    command_type: :dcm_unsubscribe,
    # do not change the NAME param unless you want to break everything
    name: 'unsubscribe',
    params: {dcm_account_codes: @conf.xact.account.dcm_account_id})
  raise "Could not create #{@command.name} command: #{@command.errors}" unless @command.post
end

When(/^I send an SMS to opt out of receiving TMS messages$/) do
  pending "Not implemented for development"  if dev_not_live?

  # begin stop request
  conn = faraday(@conf.xact.url)

  # create tms/xact twilio request
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = twilio_xact_test_number_2
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name}"
  log.info "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  @resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end

  if @resp.status == 500
    raise "Error mocking text, received HTTP 500: #{@resp.body}"
  end
end

Then(/^I should receive a STOP response$/) do
  pending "Not implemented for development"  if dev_not_live?

  resp_xml = Hash.from_xml @resp.body
  if resp_xml['Response']['Sms'] != 'stop'
    log.ap @resp
    raise 'Did not receive STOP response'
  end
end

Then(/^my subscription should be removed$/) do
  pending "Not implemented for development"  if dev_not_live?

  # encode FROM number as base64 so we're able to retrieve the subscriber record in DCM subscribers API
  @base64 = Base64.encode64(twilio_xact_test_number_2)

  conn = faraday(configatron.evolution.api_url + @base64)
  conn.headers['Content-Type'] = 'application/xml'
  conn.basic_auth(configatron.evolution.account.email_address, configatron.evolution.account.password)

  GovDelivery::Proctor.backoff_check(3.minutes, 'should remove subscriber') do
    @response = MultiXml.parse(conn.get.body)

    log.ap @response
    @response['errors'] && @response['errors']['error'] == 'Subscriber not found'
  end
end

#===STATIC========================================>

Given(/^A keyword with static content is configured for an TMS account$/) do
  @conf = configatron.accounts.sms_keyword_commands_static
  client = TmsClientManager.from_configatron(@conf)
  @keyword = client.keywords.build(name: random_string, response_text: random_string)
  @keyword.post!
end

Given(/^I send that keyword as an SMS to TMS$/) do
  conn = faraday(@conf.xact.url)
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = '+15555555555'
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name}"
  log.info "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
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

Given(/^I have an XACT account with a forward worker$/) do
  @conf = configatron.accounts.sms_keyword_commands_forward_worker
  @client = TmsClientManager.from_configatron(@conf)
end

Given(/^I register the keyword (.+)$/) do |agency|
  # Register a unique keyword each time, so that test failures can save the keyword for review without concern for future test keyword collisions
  @agency_keyword = "#{agency.downcase}#{random_string}"
  @keyword = @client.keywords.build(name: @agency_keyword)
  raise "Could not create #{@agency_keyword} keyword: #{@keyword.errors}" unless @keyword.post
end

Given(/^I register the forward command$/) do
  @command = @keyword.commands.build(
    name: "Cucumber Testing Forwarding",
    params: {
      url: 'https://xact-services-stage.herokuapp.com/knowit',
      http_method:   'get',
      strip_keyword: true
    },
    command_type: :forward
  )
  raise "Could not create Forwarding command: #{@command.errors}" unless @command.post
end

When(/^I text '(.+)' to the forward worker account$/) do |message|
  # Don't actually care about the keyword that is passed to this test
  message = message.split[1..-1].join(' ')

  conn = faraday(@conf.xact.url)
  payload = {}
  payload['To'] = @conf.sms.phone.number
  payload['From'] = '+15005550006'
  payload['AccountSid'] = @conf.sms.vendor.username
  payload['Body'] = "#{@conf.sms.prefix} #{@keyword.name} #{message}"
  log.info "Mocking text ''#{payload['Body']}'' to #{payload['To']}"
  @resp = conn.post do |req|
    req.url '/twilio_requests.xml'
    req.body = payload
  end
end

Then(/^I should receive any content as a response$/) do
  # TODO Can we find the actual message that XACT sent back?

  begin
    GovDelivery::Proctor.backoff_check(10.minutes, "for the forward worker to send an acceptable response") do
      # The API does not provide the command_actions relation on a command if there are no command actions
      # Thus, we need to be ready to catch a NoMethodError in case a command action has not been created
      # by the time the test wants to check for one.
      @command.get
      @command.try(:command_actions).try(:get)
      actions = @command.try(:command_actions).try(:collection)

      actions.any? do |action|
        action.status == 200 &&
          !action.response_body.blank? &&
          !action.response_body.include?('We are sorry, but the message you sent is not valid.')
      end if actions
    end

  rescue
    msg = test[:msg]
    msg += "\nCommand URL: #{@command.href}"
    raise $ERROR_INFO, "#{$ERROR_INFO}\n#{msg}"
  end
end