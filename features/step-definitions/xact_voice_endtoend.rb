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

def client
  if ENV['XACT_ENV'] == 'qc'
    GovDelivery::TMS::Client.new('52qxcmfNnD1ELyfyQnkq43ToTcFKDsAZ', api_root: 'https://qc-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'integration'
    GovDelivery::TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', api_root: 'https://int-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'stage'
    GovDelivery::TMS::Client.new('Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD', api_root: 'https://stage-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'prod'
    GovDelivery::TMS::Client.new('7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW', api_root: 'https://tms.govdelivery.com')
  end
end

def voice_message
  {
    1 => 'http://xact-webhook-callbacks.herokuapp.com/voice/first.mp3',
    2 => 'http://xact-webhook-callbacks.herokuapp.com/voice/second.mp3',
    3 => 'http://xact-webhook-callbacks.herokuapp.com/voice/third.mp3',
    4 => 'http://xact-webhook-callbacks.herokuapp.com/voice/fourth.mp3',
    5 => 'http://xact-webhook-callbacks.herokuapp.com/voice/fifth.mp3',
    6 => 'http://xact-webhook-callbacks.herokuapp.com/voice/sixth.mp3',
    7 => 'http://xact-webhook-callbacks.herokuapp.com/voice/seventh.mp3',
    8 => 'http://xact-webhook-callbacks.herokuapp.com/voice/eighth.mp3',
    9 => 'http://xact-webhook-callbacks.herokuapp.com/voice/ninth.mp3',
    10 => 'http://xact-webhook-callbacks.herokuapp.com/voice/tenth.mp3'
  }
end

def phone_number
  if ENV['XACT_ENV'] == 'qc'
    '+16124679346'
  elsif ENV['XACT_ENV'] == 'integration'
    '+16124679346'
  elsif ENV['XACT_ENV'] == 'stage'
    '+16124679346'
  elsif ENV['XACT_ENV'] == 'prod'
    '+16124679346'
  end
end

def random
  rand(1...10)
end

def twiliomation
  # Get your Account Sid and Auth Token from twilio.com/user/account
  account_sid = 'AC189315456a80a4d1d4f82f4a732ad77e'
  auth_token = '88e3775ad71e487c7c90b848a55a5c88'
  @client = Twilio::REST::Client.new account_sid, auth_token
end

def from_number
  if ENV['XACT_ENV'] == 'qc'
    '(651) 504-3057'
  elsif ENV['XACT_ENV'] == 'integration'
    '(651) 504-3057'
  elsif ENV['XACT_ENV'] == 'stage'
    '(651) 504-3057'
  elsif ENV['XACT_ENV'] == 'prod'
    '(651) 504-3057'
  end
end

Given(/^I am testing xact voice messaging end to end$/) do
  @message = client.voice_messages.build(play_url: voice_message[random]) # combine methods where 'random' selects the hash key at random
  @message.recipients.build(phone: phone_number) # change phone
  raise @message.errors.join(", ") unless @message.post
end

Then(/^I should be able to create a voice message and send to recipients$/) do
  # ap @message.response
  ap @message.errors if @message.errors
end

Then(/^I should be able to verify the voice message was received$/) do
  twiliomation # call to twilio call list
  sleep(10)
  @a = @client.account.calls.list(start_time: Date.today,
                                  status: 'ringing',
                                  from: from_number).each do |call|
    @b = call.uri
  end

  @request = HTTPI::Request.new # call to twilio callsid json
  @request.headers['Content-Type'] = 'application/json'
  @request.auth.basic('AC189315456a80a4d1d4f82f4a732ad77e', '88e3775ad71e487c7c90b848a55a5c88')
  @request.url = 'https://api.twilio.com' + @b
  @response = HTTPI.get(@request)

  i = 0
  until JSON.parse(@response.raw_body)['status'] == 'completed' # loop until call status = completed
    STDOUT.puts JSON.parse(@response.raw_body)['status'].red
    @response = HTTPI.get(@request)
    STDOUT.puts 'waiting for status for 10 seconds'.blue
    sleep(10)
    i += 1
  end
  puts 'Call found'.green
end
