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

S = {} # generating a hash value
S.store(1, rand(0...10_000)) # storing the hash value so we can retrieve it later on

T = {} # generating a hash value
T.store(1, rand(0...10_000)) # storing the hash value so we can retrieve it later on

# @QC-2453
Given(/^I create a new keyword with a text response$/) do
  @keyword = client.keywords.build(name: "160CHARS#{Time.now.to_i.to_s}", response_text: '160CHARS')
  raise @keyword.errors.to_s unless @keyword.post
end

Then(/^I should be able to delete the keyword$/) do
  @keyword.delete
end

# @QC-2496
Given(/^I attempt to create a keyword with a response text over 160 characters$/) do
  @object = client.keywords.build(name: '162CHARS', response_text: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient...')
  @object.post
end

# @QC-2492
Given(/^I create a new forward keyword and command$/) do
  # "#{T[1]}"
  @keyword = client.keywords.build(name: "#{T[1]}")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "#{T[1]}",
    params: {url: 'https://github.com/govdelivery/tms_client/blob/master/Appraisals', http_method: 'get'},
    command_type: :forward)
  @command.post!
  @command.params = {url: 'https://github.com/govdelivery/tms_client/blob/master/Appraisals', http_method: 'post'}
  @command.put!
end

Then(/^I should be able to delete the forward keyword$/) do
  @command.delete!
  @keyword.delete!
end

# @QC-2488
Given(/^I create a new subscribe keyword and command$/) do
  @keyword = client.keywords.build(name: "#{S[1]}")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "#{S[1]}",
    params: {dcm_account_code: "#{EmailAdmin.new.account_code}", dcm_topic_codes: ["#{EmailAdmin.new.topic_code}"]},
    command_type: :dcm_subscribe)
  @command.post!
end

Then(/^I should be able to delete the subscribe keyword$/) do
  @command.delete!
  @keyword.delete!
end

Given(/^I create a new unsubscribe keyword and command$/) do
  @keyword = client.keywords.build(name: "#{S[1]}")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "#{S[1]}",
    params: {dcm_account_codes: ["#{EmailAdmin.new.account_code}"], dcm_topic_codes: ["#{EmailAdmin.new.topic_code}"]},
    command_type: :dcm_unsubscribe)
  @command.post!
end

Then(/^I should be able to delete the unsubscribe keyword$/) do
  @command.delete!
  @keyword.delete!
end

# @QC-2452
Given(/^I create a keyword and command with an invalid account code$/) do
  @keyword = client.keywords.build(name: "#{S[1]}")
  @keyword.post!
  @object = @keyword.commands.build(
    name: "#{S[1]}",
    params: {dcm_account_code: 'CUKEAUTO_NOPE', dcm_topic_codes: ['CUKEAUTO_BROKEN']},
    command_type: :dcm_subscribe)
  @object.post #verification in next step
end


Then(/^I should expect the uuid and the id to be the same for the (.*) template$/) do |type|
  puts "#{type.capitalize} template id: #{@template.id}"
  puts "#{type.capitalize} template uuid: #{@template.uuid}"
  raise 'Both id and uuid are not the same' unless @template.id.to_s.eql?(@template.uuid.to_s)
  raise @template.errors.to_s unless @template.delete
end

Then(/^I should not be able to update the (.*) template with "(.*)" uuid$/) do |type, update_uuid|
  @template.uuid = update_uuid
  raise "Template updated successfully when it should not have" if @template.put
end
