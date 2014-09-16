require 'tms_client'
require 'uri'
require 'net/http'

$subject = Hash.new #generating a hash value
$subject.store(1, Time.new) #storing the hash value so we can retrieve it later on


def event_types
  event_type = ["sending","sent","failed","blacklisted","inconclusive","canceled"]
end    

def magic_emails
  magic_email = ["mike.sutehall@govdelivery.com"]
end    

def tms_client
    if ENV['XACT_ENV'] == 'qc'
        client = TMS::Client.new('gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp', :api_root => environment)
    elsif ENV['XACT_ENV'] == 'int'
        "http://int-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'stage'
        "http://stage-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'prod'
        "http://tms.govdelivery.com"
    end
end

def url
    if ENV['XACT_ENV'] == 'qc'
        "http://qc-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'int'
        "http://int-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'stage'
        "http://stage-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'prod'
        "http://tms.govdelivery.com"
    end
end


Given(/^the following event type$/) do
    @event_callback_uris = Hash[event_types.map {|event_type| [event_type,nil]}]
end

Then(/^a callback url exists for each event type$/) do
    @event_callback_uris.each_key do |event_type|
        @event_callback_uris[event_type] = @capi.create_callback_uri(event_type)
    end
end

And(/^a callback url is registered for each event_type$/) do 
  puts @event_callback_uris
  client = tms_client
  @event_callback_uris.each do |key,value|
    webhook = client.webhooks.build(:url=>@capi.callbacks_domain + value, :event_type=>key)
    webhook.post 
  end
end

When(/^I send an email message to the magic address of each event state$/) do
  client = tms_client  
  @message = client.email_messages.build(:body=>'Webhooks Testing',:subject=>"#{$subject[1]}")
  magic_emails.each do |magic_email|
    @message.recipients.build(:email=>magic_email)
    puts magic_email
  end
  @message.post
  puts @message.href
  puts @message.recipients
end

Then(/^the callback registered for each event state should receive a POST referring to the appropriate message$/) do
  @message.recipients.get
end








