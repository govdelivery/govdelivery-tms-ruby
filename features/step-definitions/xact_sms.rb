require 'tms_client'
require 'colored'

$bt = Hash.new
$bt.store(1, Time.new.to_s + "::" + rand(100000).to_s)

def client
    if ENV['XACT_ENV'] == 'qc'
      client = TMS::Client.new('52qxcmfNnD1ELyfyQnkq43ToTcFKDsAZ', :api_root => 'https://qc-tms.govdelivery.com') #user_id 10440 
    elsif ENV['XACT_ENV'] == 'int'
      client = TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', :api_root => 'https://int-tms.govdelivery.com') #user_id 10060
    elsif ENV['XACT_ENV'] == 'stage'
      client = TMS::Client.new('XpQ4dD4EZyykgpwvA6qh2fRXcLWLvBCq', :api_root => 'https://stage-tms.govdelivery.com') #user_id 10440
    elsif ENV['XACT_ENV'] == 'prod'
      client = TMS::Client.new('oshpe6rGFLXD63y7QQTA41gvqe5KPvnN', :api_root => 'https://tms.govdelivery.com') #user_id 10320
    end
end

Given(/^I POST a new SMS message to TMS$/) do
  client
  message = client.sms_messages.build(:body=>"#{$bt[1]}")
  message.recipients.build(:phone=>'6122003708')
  message.post
  message.recipients.collection.detect{|r| r.errors }
  puts message.href.green
end

And(/^I wait for a response from twilio$/) do
  puts 'step 2'
end

Then(/^I should be able to identify my unique message is among all SMS messages$/) do
  puts 'step 3'
end