#!/usr/bin/env ruby
# encoding: utf-8

require 'capybara'
require 'capybara/cucumber'
require 'rubygems'
require 'colored'
require 'awesome_print'
require 'twilio-ruby'
require 'date'
require 'httpi'
require 'timeout'

Capybara.default_wait_time = 300

Given(/^A voice message resource with recipients$/) do
  @message = TmsClientManager.voice_client.voice_messages.
    build(play_url: 'http://xact-webhook-callbacks.herokuapp.com/voice/tenth.mp3') # combine methods where 'random' selects the hash key at random
  @message.recipients.build(phone: '+16124679346') # change phone
end

When(/^I POST it/) do
  raise @message.errors.inspect unless @message.post
  ap @message.errors if @message.errors
end

Then(/^Twilio should complete the call$/) do
  @client = TwilioClientManager.default_client
  sleep(10)

  # TODO ????
  call = @client.account.calls.list(start_time: Date.today,
                                    status:     'ringing',
                                    from:       '(651) 504-3057').first.uri


  # call to twilio callsid json
  request                         = HTTPI::Request.new
  request.headers['Content-Type'] = 'application/json'
  request.auth.basic(configatron.test_support.twilio.account.sid , configatron.test_support.twilio.account.token)
  request.url = "https://api.twilio.com/#{call}"

  condition = proc {
    puts "GET #{request.url}"
    (JSON.parse(HTTPI.get(@request).raw_body)['status'] == 'completed').tap do |retval|
      puts 'Call found'.green if retval
    end
  }

  backoff_check(condition)
end
