#!/bin/env ruby
# encoding: utf-8
require 'colored'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'httpi'
require 'base64'
require 'multi_xml'

######################
####### Given ########
######################

######################
######## When ########
######################

## Successes

When(/^I post a new SMS message with the correct number of characters$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '5551112222')
  raise @object.errors.inspect unless @object.post
  @last_response = @object.response
end

When(/^I post a new SMS message with the correct number of characters to a formatted phone number$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '(555) 111-2222')
  raise @object.errors.inspect unless @object.post
  @last_response = @object.response
end

When(/^I post a new SMS message and retrieve the message details$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '5551112222')
  raise @object.errors.inspect unless @object.post

  sms = @object.get
  if sms.response.body['_links']['self'].include?('messages/sms')
    log.info 'message details found'.green
  else
    raise 'message details not found'.red
  end
  @last_response = @object.response
end

When(/^I post a new SMS message and retrieve the recipient details$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '5551112222')
  raise @object.errors.inspect unless @object.post
  sms = @object.get

  if sms.response.body['_links'].include?('recipients')
    log.info 'recipient details found'.green
  else
    raise 'recipient details not found'.red
  end
  @last_response = @object.response
end

When(/^I post a new SMS message to multiple recipients$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '5551112222')
  @object.recipients.build(phone: '5551112223')
  raise @object.errors.inspect unless @object.post
  @last_response = @object.response
end

When(/^I post a new SMS message to invalid recipients I should not receive failed recipients$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '55A')
  raise @object.errors.inspect unless @object.post
  @last_response = @object.response
end

When(/^I post a new SMS message with duplicate recipients$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '5551112222')
  @object.recipients.build(phone: '5551112222')
  @object.recipients.build(phone: '5551112222')
  @object.recipients.build(phone: '5551112222')
  @object.recipients.build(phone: '5551112222')
  raise @object.errors.inspect unless @object.post
  @last_response = @object.response
end

When(/^I post a new SMS message which contains special characters$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You í á é ñ ó ú ü ¿ ¡ received this message as a result of feature testing special characters within the GovDelivery platform.')
  @object.recipients.build(phone: '5551112222')
  raise @object.errors.inspect unless @object.post
  @last_response = @object.response
end

## Validations

When(/^I post a new SMS message to an empty recipient$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'You have received this message as a result of feature testing within the GovDelivery platform.')
  @object.recipients.build(phone: '')
  @object.post
  @last_response = @object.response
end

When(/^I post a new SMS message with too many characters$/) do
  @object = TmsClientManager.non_admin_client.sms_messages.build(body: 'PtFGdBXk65tYERi9yKuOAxPInGJQPrNeaIdNJ7YlLeEAxglMeoxaufoKTxJZUOEOkXo5jO84cFIyeUGHdywK2mOnUy2JM6Q9vdd2Plpce8mZFvWdtUQJgVQSDTOUwFUkLkHOLIXqGHE24CBJlTZmxOE2HuyVqYRof')
  @object.recipients.build(phone: '5551112222')
  @object.post
  @last_response = @object.response
end

