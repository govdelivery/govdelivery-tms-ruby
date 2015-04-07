#!/bin/env ruby
#encoding: utf-8


require 'tms_client'
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

$s = Hash.new #generating a hash value
$s.store(1, rand(0...10000)) #storing the hash value so we can retrieve it later on

$t = Hash.new #generating a hash value
$t.store(1, rand(0...10000)) #storing the hash value so we can retrieve it later on


#@QC-2453
Given(/^I create a new keyword with a text response$/) do
  @keyword = client.keywords.build(:name => "160CHARS", :response_text => "160CHARS") 
  STDOUT.puts @keyword.errors unless @keyword.post
end

Then(/^I should be able to create and delete the keyword$/) do
  @keyword.delete
end


#@QC-2496
Given(/^I attempt to create a keyword with a response text over 160 characters$/) do
  @keyword = client.keywords.build(:name => "162CHARS", :response_text => "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient...") 
  STDOUT.puts @keyword.errors unless @keyword.post

  if @keyword.errors["response_text"] == ["is too long (maximum is 160 characters)"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end    
end


#@QC-2492
Given(/^I create a new forward keyword and command$/) do
  #"#{$t[1]}"
  @keyword = client.keywords.build(:name => "#{$t[1]}")
  @keyword.post
  @command = @keyword.commands.build(
            :name => "#{$t[1]}", 
            :params => {:url => "https://github.com/govdelivery/tms_client/blob/master/Appraisals", :http_method => "get"}, 
            :command_type => :forward)
  @command.post
  @command.params = {:url => "https://github.com/govdelivery/tms_client/blob/master/Appraisals", :http_method => "post"}
  @command.put
end
Then(/^I should be able to delete the forward keyword$/) do
  @command.delete
  @keyword.delete
end


#@QC-2488
Given(/^I create a new subscribe keyword and command$/) do
  @keyword = client.keywords.build(:name => "#{$s[1]}")
  @keyword.post
  @command = @keyword.commands.build(
            :name => "#{$s[1]}", 
            :params => {:dcm_account_code => "#{EmailAdmin.new.account_code}", :dcm_topic_codes => ["#{EmailAdmin.new.topic_code}"]},
            :command_type => :dcm_subscribe)
  @command.post
end
And(/^I should be able to delete the subscribe keyword$/) do
  @command.delete
  @keyword.delete
end

Given(/^I create a new unsubscribe keyword and command$/) do
  @keyword = client.keywords.build(:name => "#{$s[1]}")
  @keyword.post
  @command = @keyword.commands.build(
            :name => "#{$s[1]}", 
            :params => {:dcm_account_codes => ["#{EmailAdmin.new.account_code}"], :dcm_topic_codes => ["#{EmailAdmin.new.topic_code}"]},
            :command_type => :dcm_unsubscribe)
  @command.post
end  
And(/^I should be able to delete the unsubscribe keyword$/) do
  @command.delete
  @keyword.delete
end


#@QC-2452
Given(/^I create a keyword and command with an invalid account code$/) do
  @keyword = client.keywords.build(:name => "#{$s[1]}")
  @keyword.post
  @command = @keyword.commands.build(
            :name => "#{$s[1]}", 
            :params => {:dcm_account_code => 'CUKEAUTO_NOPE', :dcm_topic_codes => ['CUKEAUTO_BROKEN']},
            :command_type => :dcm_subscribe)
  STDOUT.puts @command.errors unless @command.post  
end
Then(/^I should receive an error$/) do
  if @command.errors["params"] == ["has invalid dcm_subscribe parameters: Dcm account code is not a valid code"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end 
  @keyword.delete
end
