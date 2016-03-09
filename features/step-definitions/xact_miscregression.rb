#!/bin/env ruby
# encoding: utf-8

require 'colored'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'httpi'
require 'faraday'
require 'base64'
require 'multi_xml'

# @QC-2453
Given(/^I create a new keyword with a text response$/) do
  @keyword = TmsClientManager.voice_client.keywords.build(name: "160CHARS#{Time.now.to_i.to_s}", response_text: '160CHARS')
  raise @keyword.errors.to_s unless @keyword.post
end

Then(/^I should be able to delete the keyword$/) do
  @keyword.delete
end

# @QC-2496
Given(/^I attempt to create a keyword with a response text over 160 characters$/) do
  @object = TmsClientManager.voice_client.keywords.build(name: '162CHARS', response_text: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient...')
  @object.post
end

# @QC-2492
Given(/^I create a new forward keyword and command$/) do
  @keyword = TmsClientManager.voice_client.keywords.build(name: "forwardy")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "forwardy 1",
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
  @keyword = TmsClientManager.voice_client.keywords.build(name: "new_keyword")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "new_command",
    params: {dcm_account_code: "#{TmsClientManager.account_code}", dcm_topic_codes: ["#{TmsClientManager.topic_code}"]},
    command_type: :dcm_subscribe)
  @command.post!
end

Then(/^I should be able to delete the subscribe keyword$/) do
  @command.delete!
  @keyword.delete!
end

Given(/^I create a new unsubscribe keyword and command$/) do
  @keyword = TmsClientManager.voice_client.keywords.build(name: "newish")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "newish unsub",
    params: {dcm_account_codes: ["#{TmsClientManager.account_code}"], dcm_topic_codes: ["#{TmsClientManager.topic_code}"]},
    command_type: :dcm_unsubscribe)
  @command.post!
end

Then(/^I should be able to delete the unsubscribe keyword$/) do
  @command.delete!
  @keyword.delete!
end

# @QC-2452
Given(/^I create a keyword and command with an invalid account code$/) do
  @keyword = TmsClientManager.voice_client.keywords.build(name: "xxinvalid")
  @keyword.post!
  @object = @keyword.commands.build(
    name: "xxinvalid",
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
