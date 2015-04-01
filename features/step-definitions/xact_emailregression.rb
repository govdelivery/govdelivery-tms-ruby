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

$x = Time.new #generating a hash value



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


def mail_accounts
  if ENV['XACT_ENV'] == 'qc'
    'xactqctest1@gmail.com'
  elsif ENV['XACT_ENV'] == 'integration'
    'xactqctest1@gmail.com'
  elsif ENV['XACT_ENV'] == 'stage'
    'xactqctest1@gmail.com'
  end  
end

def password
  'govdel01!'
end  

def subject
  "XACT-533-2 Email Test for link parameters #{$x}"
end  

Mail.defaults do
  retriever_method :imap, 
   :address    => "imap.gmail.com",
   :port       => 993,
   :user_name  => mail_accounts,
   :password   => password,
   :enable_ssl => true
end



#=======================>
#=======================>
#=======================>


Given(/^I am a TMS admin$/) do
  admin
end

And(/^I send an email from an account that has link tracking params configured$/) do
  admin
  @message = client.email_messages.build(:body => '<p><a href="http://www.cnn.com">You have received this message as a result of feature testing within the GovDelivery platform. GovDelivery performs routine feature testing to ensure a high quality of service. This test message is intended for internal GovDelivery users, but may include some external recipients. There is no action required on your part.  If you have questions or concerns, please file ticket at support.govdelivery.com, or give us call at 1-800-439-1420.</a>', 
                                         :subject => "XACT-533-2 Email Test for link parameters #{$x}",
                                         :from_email => "#{from_email}")
  @message.recipients.build(:email => mail_accounts)
  STDOUT.puts @message.errors unless @message.post
end

Then(/^those params should resolve within the body of the email I send$/) do
  a=0
  until Mail.last != [] #checking to see if inbox is empty, and waiting until a message arrives
    sleep(10)
    STDOUT.puts 'waiting 10 seconds for emails to arrive'.green
    a+=1
    if a>10
      fail
    end  
  end  

  emails = Mail.last #establish emails var

  i=0
  until emails.subject = subject #telling Mail what to look for
    STDOUT.puts 'waiting for email for 6 seconds'.blue
    sleep(6)
    i+=1 
    
    if i>30
      fail 'The email didn\'t appear wthin 3 minutes'.red
    end  
  end 
  
    lines = emails.html_part.body.decoded #extracting all of the HTML out of the email since the email is MultiPart
    doc = Nokogiri::HTML.parse(lines) #Using Nokogiri to parse out the HTML to be something more readable
    URL = doc.css('p a').map { |link| link['href'] }[0] #forcing an array mapping to the first <a href> within the first <p> tag since the email is built like that
    puts 'Link found goes to: '.green 
    puts URL #outputting the extracted URL with the email
  
  if URL.include? "utf8=true"
    puts 'params found'.green
  elsif
    fail 'params not found'.red
  end  
    
    Mail.find_and_delete({:what=>:all})

    if Mail.all == []
      puts 'Inbox email deleted'.green
    end  

end



Given(/^I am a TMS user and not an admin$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should not be able to see the accounts endpoint$/) do
  pending # express the regexp above with the code you wish you had
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





























