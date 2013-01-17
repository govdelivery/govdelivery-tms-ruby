twilio_sms_sender = SmsVendor.find_by_name('Twilio Sender') || SmsVendor.create!(:name => 'Twilio Sender',
  :worker => 'TwilioMessageWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
twilio_voice_sender = VoiceVendor.find_by_name('Twilio Voice Sender') || VoiceVendor.create!(:name => 'Twilio Voice Sender',
  :worker => 'TwilioVoiceWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
sms_loopback = SmsVendor.find_by_name('Loopback SMS Sender') || SmsVendor.create!(:name => 'Loopback SMS Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => '1555111222',
  :vtype=>:sms)
voice_loopback = VoiceVendor.find_by_name('Loopback Voice Sender') || VoiceVendor.create!(:name => 'Loopback Voice Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => '1555111222',
  :vtype=>:voice)


odm_sender = EmailVendor.find_by_name('ODM Sender') || EmailVendor.create(:name => 'ODM Sender', :username => 'gd3', :password => 'R0WG38piNv5NRK0DT8mq04fU', :from => nil, :worker => 'OdmWorker')
email_loopback = EmailVendor.find_by_name('Email Loopback Sender') || EmailVendor.create(:name => 'Email Loopback Sender', :username => 'blah', :password => 'wat', :from => 'GovDelivery LoopbackSender', :worker => 'LoopbackMessageWorker')

#
# This is just stuff for DEVELOPMENT purposes
#
# $ USE_TWILIO=true rake db:seed 
#   if you want to really connect to twilio, set USE_TWILIO=true; otherwise
#   the seeds will load with loopback vendors. 
#
if Rails.env.development?

  omg = if (ENV['USE_TWILIO'] == 'true')
          puts "** using Twilio and ODM senders for default account **"
          Account.create!(:voice_vendor => twilio_voice_sender,
                          :sms_vendor => twilio_sms_sender,
                          :email_vendor => odm_sender,
                          :name => "OMG")
        else
          puts "**  using loopback senders for default account   **"
          puts "** run with USE_TWILIO=true to use Twilio/ODM senders **"
          Account.create!(:voice_vendor => voice_loopback,
                          :sms_vendor => sms_loopback,
                          :email_vendor => email_loopback,
                          :name => "OMG")
        end


  # stop requests to this account will spray out to DCM accounts ACME and VANDELAY
  omg.add_command!(:params => CommandParameters.new(:dcm_account_codes => ['ACME','VANDELAY']), :command_type => :dcm_unsubscribe)

  # SERVICES FOO => POST to http://localhost/forward
  Keyword.delete_all
  kw = Keyword.new(:name => 'SERVICES')
  kw.account = omg
  kw.vendor = omg.sms_vendor
  kw.save!
  kw.add_command!(:params => CommandParameters.new(
                              :username => "example@evotest.govdelivery.com", 
                              :password => "password", 
                              :url => "http://localhost/forward", 
                              :http_method => "POST"), :command_type => :forward)

  # SUBSCRIBE ANTHRAX => evolution API request to localhost:3001
  kw = Keyword.new(:name => 'SUBSCRIBE')
  kw.account = omg
  kw.vendor = omg.sms_vendor
  kw.save!
  kw.add_command!(:params => CommandParameters.new(:dcm_account_code => "ACME", :dcm_topic_codes => ['ANTRHAX']), :command_type => :dcm_subscribe)

  # Make the product user (admin)
  user = User.find_or_create_by_email(:email => "product@govdelivery.com", :password => "retek01!")
  user.account = omg
  user.admin = true
  user.save!
end
