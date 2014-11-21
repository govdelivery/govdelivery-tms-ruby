#!/usr/bin/env ruby 
#encoding: utf-8

require 'capybara'
require 'capybara/cucumber'
require 'rubygems'
require 'colored'
require 'awesome_print'
require 'mail'
require 'httpi'

$ct = Hash.new
$ct.store(1, Time.new.to_s + "::" + rand(100000).to_s)
expected_subject = $ct[1]

Capybara.default_wait_time = 600

When(/^I POST an EMAIL message to TMS$/) do
  @request = HTTPI::Request.new
  @request.url = 'https://int-tms.govdelivery.com/messages/email'
  @request.headers["Content-Type"] = "application/json"
  @request.auth.basic("cukeautoint@govdelivery.com", "govdel01")
  @request.body = '{"subject":"#xact_header_verification","from_name":"TMStesting@evotest.govdelivery.com", "body":"A simple email to use for verifying headers.", "recipients":[{"email":"msutehall@gmail.com"}]}'
  
  @data = HTTPI.post(@request)
  @data.code = puts (@data.code)
  ap @data.headers
end

Then(/^I should be able to verify all of the header data is correct$/) do
  if @data.headers['x-frame-options'] == "SAMEORIGIN"
  	puts 'x-frame-options are correct'.green
  else
  	fail 'x-frame-options are incorrect'.red
  end

  if @data.headers['content-type'] == "application/json;charset=utf-8"
  	puts 'content-type are correct'.green
  else
  	fail 'content-type are incorrect'.red
  end	

end