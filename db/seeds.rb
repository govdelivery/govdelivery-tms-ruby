twilio_sms_sender = Vendor.find_by_name('Twilio Sender') || Vendor.create!(:name => 'Twilio Sender',
  :worker => 'TwilioMessageWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
twilio_voice_sender = Vendor.find_by_name('Twilio Voice Sender') || Vendor.create!(:name => 'Twilio Voice Sender',
  :worker => 'TwilioVoiceWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
sms_loopback = Vendor.find_by_name('Loopback SMS Sender') || Vendor.create!(:name => 'Loopback SMS Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => 'dont care',
  :vtype=>:sms)
voice_loopback = Vendor.find_by_name('Loopback Voice Sender') || Vendor.create!(:name => 'Loopback Voice Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => 'dont care',
  :vtype=>:voice)

tms_sender =  Vendor.find_by_name('TMS Sender') ||  Vendor.create(:name => 'TMS Sender', :username => 'gd3', :password => 'R0WG38piNv5NRK0DT8mq04fU', :from => 'GovDelivery TMS', :worker => 'TmsWorker')

#
# This is just stuff for DEVELOPMENT purposes
#
# $ USE_TWILIO=true rake db:seed 
#   if you want to really connect to twilio, set USE_TWILIO=true; otherwise
#   the seeds will load with loopback vendors. 
#
if Rails.env.development?
  vendors = if (ENV['USE_TWILIO'] == 'true')
              puts "** using Twilio senders for default account **"
              [twilio_sms_sender, twilio_voice_sender]
            else
              puts "**  using loopback senders for default account   **"
              puts "** run with USE_TWILIO=true to use Twilio sender **"
              [sms_loopback, voice_loopback]
            end
  vendors << tms_sender

  omg = Account.create!(:vendors => vendors, :name => "OMG")

  # stop requests to this account will spray out to DCM accounts ACME and VANDELAY
  omg.add_action!(:params => ActionParameters.new(:dcm_account_codes => ['ACME','VANDELAY']), :action_type => Action::DCM_UNSUBSCRIBE)

  # SERVICES FOO => POST to http://localhost/forward
  Keyword.delete_all
  kw = Keyword.new(:account => omg, :vendor => omg.sms_vendor).tap { |kw| kw.name = 'SERVICES' }
  kw.save!
  kw.add_action!(:params => ActionParameters.new(
                              :username => "example@evotest.govdelivery.com", 
                              :password => "password", 
                              :url => "http://localhost/forward", 
                              :http_method => "POST"), :action_type => Action::FORWARD)

  # SUBSCRIBE ANTHRAX => evolution API request to localhost:3001
  kw = Keyword.new(:account => omg, :vendor => omg.sms_vendor).tap { |kw| kw.name = 'SUBSCRIBE' }
  kw.save!
  kw.add_action!(:params => ActionParameters.new(:dcm_account_code => "ACME", :dcm_topic_codes => ['ANTRHAX']), :action_type => Action::DCM_SUBSCRIBE)

  # Make the product user (admin)
  user = User.find_or_create_by_email(:email => "product@govdelivery.com", :password => "retek01!")
  user.account = omg
  user.admin = true
  user.save!
end
