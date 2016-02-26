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

#================2237 VOICE tests===============>
#================2237 VOICE tests===============>
#================2237 VOICE tests===============>
#================2237 VOICE tests===============>

def phone_number
  '+16123145807'
end

def phone_number_2
  '+16124679346'
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

Given(/^I created a new voice message$/) do
  @message = client.voice_messages.build(play_url: 'http://xact-webhook-callbacks.herokuapp.com/voice/fifth.mp3')
end

Then(/^I should be able to verify that multiple recipients have received the message$/) do
  @message.recipients.build(phone: phone_number)
  @message.recipients.build(phone: phone_number_2) # change phone
  puts @message.errors unless @message.post
  if @message.response.status == 201
    puts '201 Created'.green
  else
    raise 'Message was not created'.red
  end
end

Then(/^I should be able to verify the statuses using good numbers$/) do
  @message.recipients.build(phone: phone_number)
  puts @message.errors unless @message.post
  if @message.response.status == 201
    puts '201 Created'.green
  else
    raise 'Message was not created'.red
  end
end

Then(/^I should see a list of messages with appropriate attributes$/) do
  messages = client.voice_messages.get.collection
  sleep(2)

  messages.each do |message|
    %w{play_url status created_at}.each do |attr|
      raise "#{attr} was not found in message #{message.attributes}".red unless message.attributes[attr.to_sym]
    end
  end
end

Then(/^I should be able to verify the retries and expiration time$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be able to verify details of the message$/) do
  @message.recipients.build(phone: phone_number)
  raise @message.errors.join(", ") unless @message.post
  sleep(10)

  @message.get
  body = @message.response.body

  unless (voice_links = body['_links'])
    raise "No _links relation found in #{body}".red
  end

  %w{recipients failed self sent human machine busy no_answer could_not_connect}.each do |rel|
    if voice_links.include?(rel)
      puts "#{rel} relation found".green
    else
      raise "#{rel} relation was not found in #{body}".red
    end
  end

  unless (recipient_counts = body['recipient_counts'])
    raise "No recipient_counts found in #{body}".red
  end

  %w{total new sending inconclusive blacklisted canceled sent failed}.each do |recipient_count|
    if recipient_counts.has_key?(recipient_count)
      puts "#{recipient_count} found".green
    else
      raise 'Total was not found'.red
    end
  end
end
