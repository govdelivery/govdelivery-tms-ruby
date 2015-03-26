#!/bin/env ruby
#encoding: utf-8

require 'tms_admin_client'
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


def admin
  if ENV['XACT_ENV'] == 'qc'
    client = TMS::Client.new('4TvzJZtjAQ8fhaFP6HyFCseq8t7GptSu', :api_root => 'https://qc-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'integration'
    client = TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', :api_root => 'https://int-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'stage'
    client = TMS::Client.new('Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD', :api_root => 'https://stage-tms.govdelivery.com')
  end
end

def client
  if ENV['XACT_ENV'] == 'qc'
    client = TMS::Client.new('4TvzJZtjAQ8fhaFP6HyFCseq8t7GptSu', :api_root => 'https://qc-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'integration'
    client = TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', :api_root => 'https://int-tms.govdelivery.com')
  elsif ENV['XACT_ENV'] == 'stage'
    client = TMS::Client.new('Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD', :api_root => 'https://stage-tms.govdelivery.com')
  end
end

def from_email
  if ENV['XACT_ENV'] == 'qc'
    'cukeautoqc@govdelivery.com'
  elsif ENV['XACT_ENV'] == 'integration'
    'cukeautoint@govdelivery.com'
  elsif ENV['XACT_ENV'] == 'stage'
    'cukestage@govdelivery.com'
  end
end

def account_code
  if ENV['XACT_ENV'] == 'qc'
    'CUKEAUTO_QC'
  elsif ENV['XACT_ENV'] == 'integration'
    'CUKEAUTO_INT'
  elsif ENV['XACT_ENV'] == 'stage'
    'CUKEAUTO_STAGE'
  end
end

def topic_code
  if ENV['XACT_ENV'] == 'qc'
    'CUKEAUTO_QC_SMS'
  elsif ENV['XACT_ENV'] == 'integration'
    'CUKEAUTO_INT_SMS'
  elsif ENV['XACT_ENV'] == 'stage'
    'CUKEAUTO_STAGE_SMS'
  end
end

  # @attr name [String] Account name (required).
  # @attr dcm_account_codes [Array] An array of GovDelivery Communications Cloud account codes that the TMS account can access.
  # @attr stop_handler_id [Integer] ID of desired StopHandler event
  # @attr email_vendor_id [Integer] ID of desired EmailVendor
  # @attr sms_vendor_id [Integer] ID of desired SmsVendor
  # @attr voice_vendor_id [Integer] ID of desired VoiceVendor
  # @attr ipaws_vendor_id [Integer] ID of desired IPAWS::Vendor
  # @attr help_text [String] default response for when someone texts HELP to an account
  # @attr stop_text [String] default response for when someone texts STOP to an account
  # @attr default_response_text [String]
  # @attr link_tracking_parameters [String] sets default link tracking parameter

Given(/^I admin$/) do
  admin
  account = admin.accounts.build(name: 'hodsjoiajpsjapdadasdass', dcm_account_codes:['CUKEAUTO_QC'], 
    help_text: 'Account help text', stop_text: 'Account stop text', default_response_text: 'Default response text')
  STDOUT.puts account.errors unless account.post 
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



def client_2
    if ENV['XACT_ENV'] == 'qc'
      client_2 = TMS::Client.new('yopyxmk8NBnr5sa9dxwgf9sEiXpiWv1z', :api_root => 'https://qc-tms.govdelivery.com') #will send from (612) 255-6254
    elsif ENV['XACT_ENV'] == 'integration'
      client_2 = TMS::Client.new('hycb4FaXB745xxHYEifQNPdXpgrqUtr3', :api_root => 'https://int-tms.govdelivery.com') #will send from (612) 255-6225
    elsif ENV['XACT_ENV'] == 'stage'
      client_2 = TMS::Client.new('pt8EuddxvVSnEcSZojYx8TaiDFMCpiz2', :api_root => 'https://stage-tms.govdelivery.com') #will send from (612) 255-6247
    elsif ENV['XACT_ENV'] == 'prod'  
      client_2 = TMS::Client.new('7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW', :api_root => 'https://tms.govdelivery.com') #THIS TEST DOESNT RUN IN PROD
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
  elsif ENV['XACT_ENV'] == 'prod'
    'CUKE test'
  end
end

def twiliomation
  # Get your Account Sid and Auth Token from twilio.com/user/account
  account_sid = 'AC189315456a80a4d1d4f82f4a732ad77e'
  auth_token = '88e3775ad71e487c7c90b848a55a5c88'
  @client = Twilio::REST::Client.new account_sid, auth_token
end


Given(/^I rapidly send a keyword via SMS$/) do
  def rapid
    @message = client_2.sms_messages.build(:body=>prefix_and_body)
    @message.recipients.build(:phone=>phone_number_to)
    STDOUT.puts @message.errors unless @message.post
    sleep(0.5)
  end

  3.times {rapid} #execute "rapid" 3 times
  twiliomation #call to twilio call list
  sleep(2)
    @a = @client.account.messages.list({ 
        :date_created => Date.today, #grab full list of messages sent today
        :body => "This is a text response from a remote website.",
        :direction => "incoming",
        :from => phone_number_to #sort by 
        }).take(5).each do |call| 
      puts call.body 
    end

    @b = @a[0].uri #find uri of "reply" message, 

  sleep(2)  
  @request = HTTPI::Request.new #call to twilio callsid json
  @request.headers["Content-Type"] = "application/json"
  @request.auth.basic("AC189315456a80a4d1d4f82f4a732ad77e", "88e3775ad71e487c7c90b848a55a5c88")
  @request.url = 'https://api.twilio.com' + @b
  @response = HTTPI.get(@request)
    #binding.pry
  puts @response.raw_body

  sleep(2)
  i = 0
  until JSON.parse(@response.raw_body)["body"] == "This is a text file from a remote website." #loop until call status = completed
    STDOUT.puts JSON.parse(@response.raw_body)["status"].yellow
    @response = HTTPI.get(@request) 
    STDOUT.puts 'waiting for status for 6 seconds'.blue
    sleep(6)
    i+=1 
    if i>10
      fail 'waited 60 seconds for message to be delivered, but it was not found.'.red
    end  
  end 
  puts 'Message found'.green 
end



Given(/^I send an SMS with an invalid word or command$/) do
  sleep(20)
  @message = client_2.sms_messages.build(:body=>'ABCDEF jabberwocky')
  @message.recipients.build(:phone=>phone_number_to)
  STDOUT.puts @message.errors unless @message.post
  #ap @message.response


  twiliomation #call to twilio call list
  sleep(10)
    @a = @client.account.messages.list({ 
          :date_created => Date.today, #grab full list of messages sent today
          :to => phone_number_from, #sort by
          #:direction => "incoming"
          }).each do |call| 
    end
    @b = @a[0].uri #find uri of "reply" message, 

  sleep(2)  
  @request = HTTPI::Request.new #call to twilio callsid json
  @request.headers["Content-Type"] = "application/json"
  @request.auth.basic("AC189315456a80a4d1d4f82f4a732ad77e", "88e3775ad71e487c7c90b848a55a5c88")
  @request.url = 'https://api.twilio.com' + @b
  @response = HTTPI.get(@request)
    #binding.pry
  puts @response.raw_body

  sleep(2)
  i = 0
  until JSON.parse(@response.raw_body)["body"] == "Visit Help@govdelivery.com for help or more at 800-314-0147. Reply STOP to cancel. Msg&Data rates may apply. 5msgs/month." #loop until call status = completed
    STDOUT.puts JSON.parse(@response.raw_body)["status"].yellow
    @response = HTTPI.get(@request) 
    STDOUT.puts 'waiting for status for 5 seconds'.blue
    sleep(5)
    i+=1 
    if i>9
      fail 'waited 45 seconds for message to be delivered, but it was not found.'.red
    end  
  end 
  puts 'Help message found'.green 
end



Given(/^I send an SMS to a shared account with an invalid prefix$/) do
  sleep(20)
  @message = client_2.sms_messages.build(:body=>'ABCDEF help')
  @message.recipients.build(:phone=>phone_number_to)
  STDOUT.puts @message.errors unless @message.post
  #ap @message.response

  twiliomation #call to twilio call list
  sleep(1)
    @a = @client.account.messages.list({ 
          :date_created => Date.today, #grab full list of messages sent today
          :to => phone_number_from, #sort by
          :direction => "reply"
          }).each do |call| 
    end
    @b = @a[0].uri #find uri of "reply" message, 
  
  sleep(2)
  @request = HTTPI::Request.new #call to twilio callsid json
  @request.headers["Content-Type"] = "application/json"
  @request.auth.basic("AC189315456a80a4d1d4f82f4a732ad77e", "88e3775ad71e487c7c90b848a55a5c88")
  @request.url = 'https://api.twilio.com' + @b
  @response = HTTPI.get(@request)
    #binding.pry
  puts @response.raw_body
  
  sleep(2)
  i = 0
  until JSON.parse(@response.raw_body)["body"] == "Visit Help@govdelivery.com for help or more at 800-314-0147. Reply STOP to cancel. Msg&Data rates may apply. 5msgs/month." #loop until call status = completed
    STDOUT.puts JSON.parse(@response.raw_body)["status"].yellow
    @response = HTTPI.get(@request) 
    STDOUT.puts 'waiting for status for 5 seconds'.blue
    sleep(5)
    i+=1 
    if i>9 #fails after 45 seconds
      fail 'waited 45 seconds for message to be delivered, but it was not found.'.red
    end  
  end 
  puts 'Help message found'.green 
end



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

def voice_message
  voice_message = 
  {
    1 => "http://xact-webhook-callbacks.herokuapp.com/voice/first.mp3",
    2 => "http://xact-webhook-callbacks.herokuapp.com/voice/second.mp3",
    3 => "http://xact-webhook-callbacks.herokuapp.com/voice/third.mp3",
    4 => "http://xact-webhook-callbacks.herokuapp.com/voice/fourth.mp3",
    5 => "http://xact-webhook-callbacks.herokuapp.com/voice/fifth.mp3",
    6 => "http://xact-webhook-callbacks.herokuapp.com/voice/sixth.mp3",
    7 => "http://xact-webhook-callbacks.herokuapp.com/voice/seventh.mp3",
    8 => "http://xact-webhook-callbacks.herokuapp.com/voice/eighth.mp3",
    9 => "http://xact-webhook-callbacks.herokuapp.com/voice/ninth.mp3",
    10 => "http://xact-webhook-callbacks.herokuapp.com/voice/tenth.mp3" 
  }
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
  @message = client.voice_messages.build(:play_url => voice_message[random]) #combine methods where 'random' selects the hash key at random
end

Then(/^I should be able to verify that multiple recipients have received the message$/) do
    @message.recipients.build(:phone => phone_number)
    @message.recipients.build(:phone => phone_number_2) #change phone
    STDOUT.puts @message.errors unless @message.post
  if @message.response.status == 201
    puts '201 Created'.green
  elsif
    fail 'Message was not created'.red
    @message.errors
    ap @message.errors
  end  
end


Then(/^I should be able to verify the statuses using good numbers$/) do
    @message.recipients.build(:phone => phone_number)
    STDOUT.puts @message.errors unless @message.post
  if @message.response.status == 201
    puts '201 Created'.green
  elsif
    fail 'Message was not created'.red
    @message.errors
    ap @message.errors
  end 
end

Then(/^I should be able to verify the incoming message was received$/) do
  @message = client.voice_messages.get

  sleep(2)
  puts @message.collection[random].attributes

  if @message.collection[random].attributes.include?(:play_url)
    puts 'Play url found'.green
  elsif
    fail 'Play url was not found'.red
    @message.errors
    ap @message.errors
  end

  if @message.collection[random].attributes.include?(:status)
    puts 'Status found'.green
  elsif
    fail 'Status was not found'.red
    @message.errors
    ap @message.errors
  end

  if @message.collection[random].attributes.include?(:created_at)
    puts 'Created at found'.green
  elsif
    fail 'Created at was not found'.red
    @message.errors
    ap @message.errors
  end

  if @message.collection[random].attributes[:play_url].nil?
    fail 'Play url was not found'.red
    @message.errors
    ap @message.errors
  end

  if @message.collection[random].attributes[:created_at].nil?
    fail 'Play url was not found'.red
    @message.errors
    ap @message.errors
  end

  if @message.collection[random].attributes[:status].nil?
    fail 'Play url was not found'.red
    @message.errors
    ap @message.errors
  end
end

Then(/^I should be able to verify the retries and expiration time$/) do
  pending # express the regexp above with the code you wish you had
end

# Given(/^I created a new voice message with too many characters in the play url$/) do
#   @message = client.voice_messages.build(:play_url => 'http://www.longurlmaker.com/go?id=loftylingering7NanoRef152600EasyURLoutstretched1Doiop63eURLPie005s99c75spread%2Bout08NotLongbURLvi53MooURLlongishB650100101eEzURL7sdrawn%2Boutt001201FwdURLShortenURLaA2N11dq210eprotracted114GetShortydeepspun%2Bout713iGetShortyoutstretched2EzURLstretchSitelutionslingeringURLPieDigBiglongish01sustainedexpandedTinyLink0t31continued3tall16longish201stretch9lengthy48DecentURL01019ffprolongeddrawn%2Boutlingeringgangling0619c9GetShorty5Shrinkr9spread%2Bouthighlnk.inbn2lengthy4301URLa11g4GetShorty7ShortURL11612stretchingShrinkrX.se76f5stretching2stretch2espread%2Bout90kA2N3b6cenlarged4EzURLe47750221high9939ShrinkURLan8far%2Boffx6URL00026URL34enlargedtallqA2Nspread%2BoutDwarfurlnm8URLvi78n240StartURL7ganglingTinyURL1Minilien5U76024ct1NotLongb02deep6ue1d0uaf0EasyURLrSmallr3loftyDecentURLj02x3Is.gdB65150rj1spread%2Bout00running45greatz04YATUCganglingSHurl301URL2DigBig51Dwarfurlexpanded3541expanded90931p80enduringURLcut073tally8ShortURL14distantUlimit77dj01024xBeam.tot9d16c11ShortenURL6369Redirx14enduring16r7bShredURLSmallrlnk.instretching009bFly2far%2Breaching1MetamarkRubyURL4prolongedrremote001TraceURL9stretching10SimURLco0longish7SHurlB65Shim8URLCutter404cSitelutionsSimURL0continuedbEasyURLm8Shrtndhf0URLHawk1prolonged15lasting2h011ShortURL190Ulimit05ShortURLenduringsustaineddEasyURLTinyLink401stretch7lengthyy0Beam.toelongatedXilfMooURL2alingeringzadistant7ShortURLdrawn%2Bout9zexpanded1stretching95017spun%2Bout746running01sustainedstretchoefgangling0xnxa11q8r8801FwdURLlanky8spread%2Boutd6a4loftyRedirx192EzURL9034URLCutterb18516URL0dv3f5i1lengthenedhighNe1671oNe1a0tallShrtnd04Smallr41ShoterLinkdrawn%2BoutURLPie5912ShoterLinkvstringy5far%2BreachinggDigBigf16Beam.tof0deep9agNotLonge6protractedremoteb0prolongedt02x03talllengthyShrinkURLc1continuedprolongedebIs.gdrangy60428spread%2BoutNutshellURLganglingt08sustained0TightURL14outstretched6stretch8a971drawn%2Bout0cA2NlTinyLinkdrawn%2Bout1LiteURL0distantstretching527u5nMetamarkURLPie0lanky3lengthenedlankyShortURL9drawn%2BoutShortenURL0a1distant302301URLrunning6a1URLCutter7100Ulimitlongish11gaiShoterLink81fRubyURL0011T')
# end

# Then(/^I should be able to verify that an error is received$/) do
#   @message.recipients.build(:phone => phone_number)
#     # binding.pry
#   STDOUT.puts @message.errors unless @message.post

#   if @message.response.status == 500
#     puts 'error found'.green
#   else
#     fail 'error not found'.red
#   end
# end

Then(/^I should be able to verify details of the message$/) do
  @message.recipients.build(:phone => phone_number)
    STDOUT.puts @message.errors unless @message.post
    sleep(10)
    
    voice = @message.get
    # binding.pry
    
  if voice.response.body["_links"].include?("recipients")
    puts 'Recipients found'.green
  elsif
    fail 'Recipients was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["_links"].include?("failed")
    puts 'Failed found'.green
  elsif
    fail 'Failed was not found'.red
    @message.errors
    ap @message.errors
  end

  if voice.response.body["_links"].include?("self")
    puts 'Self found'.green
  elsif
    fail 'Self was not found'.red
    @message.errors
    ap @message.errors
  end  

  if voice.response.body["_links"].include?("sent")
    puts 'Sent found'.green
  elsif
    fail 'Sent was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["_links"].include?("human")
    puts 'Human found'.green
  elsif
    fail 'Human was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["_links"].include?("machine")
    puts 'Machine found'.green
  elsif
    fail 'Machine was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["_links"].include?("busy")
    puts 'Busy found'.green
  elsif
    fail 'Busy was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["_links"].include?("no_answer")
    puts 'No Answer found'.green
  elsif
    fail 'No Answer was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["_links"].include?("could_not_connect")
    puts 'Cound not connect found'.green
  elsif
    fail 'Could not connect was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["recipient_counts"].include?("total")
    puts 'Total found'.green
  elsif
    fail 'Total was not found'.red
    @message.errors
    ap @message.errors
  end 

  if voice.response.body["recipient_counts"].include?("new")
    puts 'New found'.green
  elsif
    fail 'New was not found'.red
    @message.errors
    ap @message.errors
  end  

  if voice.response.body["recipient_counts"].include?("sending")
    puts 'Sending found'.green
  elsif
    fail 'Sending was not found'.red
    @message.errors
    ap @message.errors
  end  

  if voice.response.body["recipient_counts"].include?("inconclusive")
    puts 'Inconclusive found'.green
  elsif
    fail 'Inconclusive was not found'.red
    @message.errors
    ap @message.errors
  end

  if voice.response.body["recipient_counts"].include?("blacklisted")
    puts 'Blacklisted found'.green
  elsif
    fail 'Blacklisted was not found'.red
    @message.errors
    ap @message.errors
  end

  if voice.response.body["recipient_counts"].include?("canceled")
    puts 'Canceled found'.green
  elsif
    fail 'Canceled was not found'.red
    @message.errors
    ap @message.errors
  end

  if voice.response.body["recipient_counts"].include?("sent")
    puts 'Sent found'.green
  elsif
    fail 'Sent was not found'.red
    @message.errors
    ap @message.errors
  end

  if voice.response.body["recipient_counts"].include?("failed")
    puts 'Failed found'.green
  elsif
    fail 'Failed was not found'.red
    @message.errors
    ap @message.errors
  end
end





















