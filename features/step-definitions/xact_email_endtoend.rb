#!/usr/bin/env ruby
# encoding: utf-8

require 'awesome_print'
require 'capybara'
require 'capybara/cucumber'
require 'colored'
require 'govdelivery-tms'
require 'mail'
require 'mechanize'
require 'rubygems'

World(Helpy)

When(/^I POST a new EMAIL message to TMS$/) do
  @expected_reply_to = @conf_xact.user.reply_to_address
  @expected_errors_to = @conf_xact.user.bounce_address

  post_message
end

# steps
Given(/A non-admin user/) do
  initialize_variables
end

Given(/An admin user/) do
  initialize_variables
  unless (@conf_xact.user.token = ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN'])
    raise "ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN'] is not set"
  end
end

When(/^I POST a new EMAIL message to TMS using a non-default from address$/) do
  @expected_reply_to = @conf_xact.user.reply_to_address_two
  @expected_errors_to = @conf_xact.user.bounce_address_two
  post_message from_email: @conf_xact.user.from_address_two
end

When(/^I POST a new EMAIL message to TMS using a random from address$/) do
  @expected_reply_to = "product-noexist@evotest.govdelivery.com"
  @expected_errors_to = "product-noexist@evotest.govdelivery.com"
  post_message from_email: "product-noexist@evotest.govdelivery.com"
end

When(/^I POST a new EMAIL message to TMS with long macro replacements$/) do
  post_message body: %Q|[[MAC1]]\n\n[[MAC2]]\n\n<a href="#{@expected_link}">With a link</a>|, macros: {'MAC1' => 'a'*800, 'MAC1' => 'b'*150}
end

Then(/^I go to Gmail to check for message delivery$/) do
  next if dev_not_live?
  validate_message
end
