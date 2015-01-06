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

$s = Hash.new #generating a hash value
$s.store(1, rand(0...10000)) #storing the hash value so we can retrieve it later on

$t = Hash.new #generating a hash value
$t.store(1, rand(0...10000)) #storing the hash value so we can retrieve it later on



def client
    if ENV['XACT_ENV'] == 'qc'
      client = TMS::Client.new('52qxcmfNnD1ELyfyQnkq43ToTcFKDsAZ', :api_root => 'https://qc-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'integration'
      client = TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', :api_root => 'https://int-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'stage'
      client = TMS::Client.new('Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD', :api_root => 'https://stage-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'prod'
      client = TMS::Client.new('7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW', :api_root => 'https://tms.govdelivery.com')
    end
end

def from_email
    if ENV['XACT_ENV'] == 'qc'
      'cukeautoqc@govdelivery.com'
    elsif ENV['XACT_ENV'] == 'integration'
      'cukeautoint@govdelivery.com'
    elsif ENV['XACT_ENV'] == 'stage'
      'cukestage@govdelivery.com'
    elsif ENV['XACT_ENV'] == 'prod'
      'cukeprod@govdelivery.com'
    end
end

def account_code
    if ENV['XACT_ENV'] == 'qc'
      'CUKEAUTO_QC'
    elsif ENV['XACT_ENV'] == 'integration'
      'CUKEAUTO_INT'
    elsif ENV['XACT_ENV'] == 'stage'
      'CUKEAUTO_STAGE'
    elsif ENV['XACT_ENV'] == 'prod'
      'CUKEAUTO_PROD'
    end
end

def topic_code
    if ENV['XACT_ENV'] == 'qc'
      'CUKEAUTO_QC_SMS'
    elsif ENV['XACT_ENV'] == 'integration'
      'CUKEAUTO_INT_SMS'
    elsif ENV['XACT_ENV'] == 'stage'
      'CUKEAUTO_STAGE_SMS'
    elsif ENV['XACT_ENV'] == 'prod'
      'CUKEAUTO_PROD_SMS'
    end
end

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
            :params => {:dcm_account_code => "#{account_code}", :dcm_topic_codes => ["#{topic_code}"]},
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
            :params => {:dcm_account_codes => ["#{account_code}"], :dcm_topic_codes => ["#{topic_code}"]},
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


#================2239 tests===============>



Given(/^I verify the ability to disable open and click tracking in my EMAIL sends$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}",
                                         :click_tracking_enabled => false,
                                         :open_tracking_enabled => false)
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  @message.recipients.build(:email=>'regressiontest2@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  email = @message.get

  if email.response.body["click_tracking_enabled"] == false
    puts 'click tracking disabled'.green
  else
    puts email.response.body["click_tracking_enabled"]
    fail 'click tracking not disabled'.red
  end

  if email.response.body["open_tracking_enabled"] == false
    puts 'open tracking disabled'.green
  else
    puts email.response.body["open_tracking_enabled"]
    fail 'open tracking not disabled'.red
  end
end

Given(/^I post a new EMAIL with message and recipient MACROS$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery [[city]] platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}",
                                         :macros => {"city"=>"Saint Paul"})
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  email = @message.get

  if email.response.body["macros"] = '{"city"=>"Saint Paul"}'
    puts 'macros enabled'.green
  else
    puts email.response.body["macros"]
    fail 'no macros found'.red
  end
end

Given(/^I post a new EMAIL message with an empty BODY produces an error$/) do
  @message = client.email_messages.build(:body => '', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors["body"] == ["can't be blank"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end

Given(/^I post a new EMAIL message with an empty SUBJECT produces an error$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => '',
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors["subject"] == ["can't be blank"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end

Given(/^I post a new EMAIL message to multiple RECIPIENTS$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  @message.recipients.build(:email=>'regressiontest2@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new EMAIL message with no RECIPIENTS produces an error$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}")
  STDOUT.puts @message.errors unless @message.post
  if @message.errors["recipients"] == ["must contain at least one valid recipient"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end

Given(/^I post a new EMAIL message and retrieve the list recipient counts\/states$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery [[city]] platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}",
                                         :macros => {"city"=>"Saint Paul"})
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  email = @message.get
  
#ap email.response.body

  if email.response.body["_links"]["self"].include?("messages/email")
    puts 'self found'.green
  else
    puts email.response.body["_links"]
    fail 'self not found'.red
  end

  if email.response.body["_links"]["recipients"].include?("recipients")
    puts 'recipients found'.green
  else
    puts email.response.body["_links"]
    fail 'recipients not found'.red
  end
end

Given(/^I post a new EMAIL message with HTML within the message body$/) do
  @message = client.email_messages.build(:body => '<p><a href="http://govdelivery.com">You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.</a>',
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  @message.recipients.build(:email=>'govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new EMAIL message with inline CSS in the message$/) do
  @message = client.email_messages.build(:body => 'A message with CSS. <div style=\"background-color:#c0c0c0; margin-left:auto; margin-right:auto; font-family: Arial, Helvetica, Tahoma; font-size: 14px; font-weight: 200;\"><img src=\"https://groups.govdelivery.com/inovem/sites/site10/custom/images/gd-logo_glow2.png\"><br>You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.<br></div>', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  @message.recipients.build(:email=>'govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new EMAIL message with a VALID and INVALID RECIPIENT produces an email$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  @message.recipients.build(:email=>'govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new EMAIL message with an empty FROM_EMAIL produces an error$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => '')
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors["from_email"] == ["can't be blank", "is not authorized to send on this account"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end

Given(/^I post a new EMAIL message with an empty REPLY_TO produces an email$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}",
                                         :reply_to => '')
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new EMAIL message with an empty ERRORS_TO produces an email$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => "#{from_email}",
                                         :errors_to => '')
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new EMAIL message with an invalid FROM_EMAIL produces an error$/) do
  @message = client.email_messages.build(:body => 'You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.', 
                                         :subject => 'Regression Test email send',
                                         :from_email => 'XXXXye3h2d9b2gnh9hx929@evotest.govdelivery.com')
  @message.recipients.build(:email=>'regressiontest1@sink.govdelivery.com')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors["from_email"] == ["is not authorized to send on this account"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end



#================1976 tests===============>




Given(/^I post a new SMS message with too many characters$/) do
  @message = client.sms_messages.build(:body=>'PtFGdBXk65tYERi9yKuOAxPInGJQPrNeaIdNJ7YlLeEAxglMeoxaufoKTxJZUOEOkXo5jO84cFIyeUGHdywK2mOnUy2JM6Q9vdd2Plpce8mZFvWdtUQJgVQSDTOUwFUkLkHOLIXqGHE24CBJlTZmxOE2HuyVqYRof')
  @message.recipients.build(:phone=>'5551112222')
  STDOUT.puts @message.errors unless @message.post
  if @message.errors["body"] == ["is too long (maximum is 160 characters)"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end

Given(/^I post a new SMS message with the correct number of characters$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'5551112222')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message with the correct number of characters to a formatted phone number$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'(555) 111-2222')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message and retrieve the message details$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'5551112222')
  STDOUT.puts @message.errors unless @message.post

  sms = @message.get
  if sms.response.body["_links"]["self"].include?("messages/sms")
    puts 'message details found'.green
  else
    fail 'message details not found'.red
  end    
end

Given(/^I post a new SMS message and retrieve the recipient details$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'5551112222')
  STDOUT.puts @message.errors unless @message.post
  sms = @message.get

  if sms.response.body["_links"].include?("recipients")
    puts 'recipient details found'.green
  else
    fail 'recipient details not found'.red
  end
end

Given(/^I post a new SMS message to multiple recipients$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'5551112222')
  @message.recipients.build(:phone=>'5551112223')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message to an empty recipient$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'')
  STDOUT.puts @message.errors unless @message.post
    if @message.errors["recipients"] == ["must contain at least one valid recipient"]
    puts 'error found'.green
  else
    fail 'error not found'.red
  end
end

Given(/^I post a new SMS message to invalid recipients I should not receive failed recipients$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'55A')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message with duplicate recipients$/) do
  @message = client.sms_messages.build(:body=>'You have received this message as a result of feature testing within the GovDelivery platform.')
  @message.recipients.build(:phone=>'5551112222')
  @message.recipients.build(:phone=>'5551112222')
  @message.recipients.build(:phone=>'5551112222')
  @message.recipients.build(:phone=>'5551112222')
  @message.recipients.build(:phone=>'5551112222')
  STDOUT.puts @message.errors unless @message.post
end

Given(/^I post a new SMS message which contains special characters$/) do
  @message = client.sms_messages.build(:body=>'You í á é ñ ó ú ü ¿ ¡ received this message as a result of feature testing special characters within the GovDelivery platform.')
  @message.recipients.build(:phone=>'5551112222')
  STDOUT.puts @message.errors unless @message.post
end





