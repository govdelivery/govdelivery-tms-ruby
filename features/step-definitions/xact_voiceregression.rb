#!/bin/env ruby
# encoding: utf-8

require 'colored'
require 'json'
require 'awesome_print'
require 'httpi'
require 'base64'

Given(/^I created a new voice message$/) do
  @message = TmsClientManager.voice_client.voice_messages.build(play_url: 'http://xact-webhook-callbacks.herokuapp.com/voice/fifth.mp3')
end

When(/^I add phone number '(.*)' to the message$/) do |phone|
  @message.recipients.build(phone: phone)
end

Then(/^I should see a list of messages with appropriate attributes$/) do
  messages = TmsClientManager.voice_client.voice_messages.get.collection
  sleep(2)

  messages.each do |message|
    %w{play_url status created_at}.each do |attr|
      raise "#{attr} was not found in message #{message.attributes}".red unless message.attributes[attr.to_sym]
    end
  end
end

Then(/^I should be able to verify details of the message$/) do
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
