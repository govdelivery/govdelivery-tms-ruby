#!/bin/env ruby
# encoding: utf-8
require 'colored'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'httpi'
require 'pry'
require 'faraday'
require 'base64'
require 'multi_xml'
require 'pry'

#================1976 tests===============>

Given(/^I post a new SMS message with too many characters$/) do
  @message = client.sms_messages.build(body: 'PtFGdBXk65tYERi9yKuOAxPInGJQPrNeaIdNJ7YlLeEAxglMeoxaufoKTxJZUOEOkXo5jO84cFIyeUGHdywK2mOnUy2JM6Q9vdd2Plpce8mZFvWdtUQJgVQSDTOUwFUkLkHOLIXqGHE24CBJlTZmxOE2HuyVqYRof')
  @message.recipients.build(phone: '5551112222')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors['body'] == ['is too long (maximum is 160 characters)']
    puts 'error found'.green
  else
    raise 'error not found'.red
  end
end

Given(/^I post a new SMS message with the correct number of characters$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '5551112222')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message with the correct number of characters to a formatted phone number$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '(555) 111-2222')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message and retrieve the message details$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '5551112222')
  STDOUT.puts @message.errors unless @message.post

  sms = @message.get
  if sms.response.body['_links']['self'].include?('messages/sms')
    puts 'message details found'.green
  else
    raise 'message details not found'.red
  end
end

Given(/^I post a new SMS message and retrieve the recipient details$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '5551112222')
  STDOUT.puts @message.errors unless @message.post
  sms = @message.get

  if sms.response.body['_links'].include?('recipients')
    puts 'recipient details found'.green
  else
    raise 'recipient details not found'.red
  end
end

Given(/^I post a new SMS message to multiple recipients$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '5551112222')
  @message.recipients.build(phone: '5551112223')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message to an empty recipient$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors['recipients'] == ['must contain at least one valid recipient']
    puts 'error found'.green
  else
    raise 'error not found'.red
  end
end

Given(/^I post a new SMS message to invalid recipients I should not receive failed recipients$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '55A')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message with duplicate recipients$/) do
  @message = client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(phone: '5551112222')
  @message.recipients.build(phone: '5551112222')
  @message.recipients.build(phone: '5551112222')
  @message.recipients.build(phone: '5551112222')
  @message.recipients.build(phone: '5551112222')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message which contains special characters$/) do
  @message = client.sms_messages.build(body: 'You í á é ñ ó ú ü ¿ ¡ received this message as a result of feature testing special characters within the GovDelivery platform.')
  @message.recipients.build(phone: '5551112222')
  STDOUT.puts @message.errors unless @message.post
end

def client_2
  if ENV['XACT_ENV'] == 'qc'
    GovDelivery::TMS::Client.new('yopyxmk8NBnr5sa9dxwgf9sEiXpiWv1z', api_root: 'https://qc-tms.govdelivery.com') # will send from (612) 255-6254
  elsif ENV['XACT_ENV'] == 'integration'
    GovDelivery::TMS::Client.new('hycb4FaXB745xxHYEifQNPdXpgrqUtr3', api_root: 'https://int-tms.govdelivery.com') # will send from (612) 255-6225
  elsif ENV['XACT_ENV'] == 'stage'
    GovDelivery::TMS::Client.new('pt8EuddxvVSnEcSZojYx8TaiDFMCpiz2', api_root: 'https://stage-tms.govdelivery.com') # will send from (612) 255-6247
  elsif ENV['XACT_ENV'] == 'prod'
    GovDelivery::TMS::Client.new('7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW', api_root: 'https://tms.govdelivery.com') # THIS TEST DOESNT RUN IN PROD
  end
end

def phone_number_to
  if ENV['XACT_ENV'] == 'qc'
    '+16519684981'
  elsif ENV['XACT_ENV'] == 'integration'
    '+16519641178'
  elsif ENV['XACT_ENV'] == 'stage'
    '+16124247727'
  end
end

def phone_number_from
  if ENV['XACT_ENV'] == 'qc'
    '(612) 255-6254'
  elsif ENV['XACT_ENV'] == 'integration'
    '(612) 255-6225'
  elsif ENV['XACT_ENV'] == 'stage'
    '(612) 255-6247'
  end
end

def prefix_and_body
  if ENV['XACT_ENV'] == 'qc'
    'CUKE test'
  elsif ENV['XACT_ENV'] == 'integration'
    'CUKEINT test'
  elsif ENV['XACT_ENV'] == 'stage'
    'CUKE test'
  end
end

def twiliomation
  # Get your Account Sid and Auth Token from twilio.com/user/account
  account_sid = 'AC189315456a80a4d1d4f82f4a732ad77e'
  auth_token = '88e3775ad71e487c7c90b848a55a5c88'
  @client = Twilio::REST::Client.new account_sid, auth_token
end

Given(/^I send an SMS with an invalid word or command$/) do
  sleep(20)
  @message = client_2.sms_messages.build(body: 'ABCDEF jabberwocky')
  @message.recipients.build(phone: phone_number_to)
  STDOUT.puts @message.errors unless @message.post
  # ap @message.response

  twiliomation # call to twilio call list
  sleep(10)
  @a = @client.account.messages.list(date_created: Date.today, # grab full list of messages sent today
                                     to: phone_number_from, # sort by
                                     direction: 'incoming').each do |_call|
  end
  @b = @a[0].uri # find uri of "reply" message,

  sleep(2)
  @request = HTTPI::Request.new # call to twilio callsid json
  @request.headers['Content-Type'] = 'application/json'
  @request.auth.basic('AC189315456a80a4d1d4f82f4a732ad77e', '88e3775ad71e487c7c90b848a55a5c88')
  @request.url = 'https://api.twilio.com' + @b
  @response = HTTPI.get(@request)
  puts @response.raw_body

  sleep(2)
  i = 0
  until JSON.parse(@response.raw_body)['body'] == 'Visit Help@govdelivery.com for help or more at 800-314-0147. Reply STOP to cancel. Msg&Data rates may apply. 5msgs/month.' # loop until call status = completed
    STDOUT.puts JSON.parse(@response.raw_body)['status'].yellow
    @response = HTTPI.get(@request)
    STDOUT.puts 'waiting for status for 5 seconds'.blue
    sleep(5)
    i += 1
    if i > 9
      raise 'waited 45 seconds for message to be delivered, but it was not found.'.red
    end
  end
  puts 'Help message found'.green
end

Given(/^I send an SMS to a shared account with an invalid prefix$/) do
  sleep(20)
  @message = client_2.sms_messages.build(body: 'ABCDEF help')
  @message.recipients.build(phone: phone_number_to)
  STDOUT.puts @message.errors unless @message.post
  # ap @message.response

  twiliomation # call to twilio call list
  sleep(1)
  @a = @client.account.messages.list(date_created: Date.today, # grab full list of messages sent today
                                     to: phone_number_from, # sort by
                                     direction: 'reply').each do |_call|
  end
  @b = @a[0].uri # find uri of "reply" message,

  sleep(2)
  @request = HTTPI::Request.new # call to twilio callsid json
  @request.headers['Content-Type'] = 'application/json'
  @request.auth.basic('AC189315456a80a4d1d4f82f4a732ad77e', '88e3775ad71e487c7c90b848a55a5c88')
  @request.url = 'https://api.twilio.com' + @b
  @response = HTTPI.get(@request)
  puts @response.raw_body

  sleep(2)
  i = 0
  until JSON.parse(@response.raw_body)['body'] == 'Visit Help@govdelivery.com for help or more at 800-314-0147. Reply STOP to cancel. Msg&Data rates may apply. 5msgs/month.' # loop until call status = completed
    STDOUT.puts JSON.parse(@response.raw_body)['status'].yellow
    @response = HTTPI.get(@request)
    STDOUT.puts 'waiting for status for 5 seconds'.blue
    sleep(5)
    i += 1
    if i > 9 # fails after 45 seconds
      raise 'waited 45 seconds for message to be delivered, but it was not found.'.red
    end
  end
  puts 'Help message found'.green
end

Then(/^I should not be able to update the sms template with (.*) uuid$/) do |update_uuid|
  @sms_template.get!
  @sms_template.uuid = update_uuid
  raise "Template updated successfully when it should not have" if @sms_template.put
  updated_template = @sms_template.get!
  raise "Both uuids are not matching" unless @sms_template.uuid.eql?updated_template.uuid
end