###
# WARNING
#
# Don't try to do this, you will run into all kinds of problems: 
#
#   rake db:migrate:full_rebuild db:seed
#
# Instead, do this:
#
#   rake db:migrate:full_rebuild
#   rake db:seed
##

twilio_sms_sender = SmsVendor.find_or_create_by_name!(:name => 'Twilio Sender',
                                                      :worker => 'TwilioMessageWorker',
                                                      :username => Rails.configuration.twilio_username,
                                                      :password => Rails.configuration.twilio_password,
                                                      :from => Rails.configuration.twilio_number)
twilio_voice_sender = VoiceVendor.find_or_create_by_name!(:name => 'Twilio Voice Sender',
                                                          :worker => 'TwilioVoiceWorker',
                                                          :username => Rails.configuration.twilio_username,
                                                          :password => Rails.configuration.twilio_password,
                                                          :from => Rails.configuration.twilio_number)
sms_loopback = SmsVendor.find_or_create_by_name!(:name => 'Loopback SMS Sender',
                                                 :worker => 'LoopbackSmsWorker',
                                                 :username => 'sms_loopback_username',
                                                 :password => 'dont care',
                                                 :from => '+15551112222')
voice_loopback = VoiceVendor.find_or_create_by_name!(:name => 'Loopback Voice Sender',
                                                     :worker => 'LoopbackVoiceWorker',
                                                     :username => 'voice_loopback_username',
                                                     :password => 'dont care',
                                                     :from => '1555111222')


odm_sender = EmailVendor.find_or_create_by_name!(
    :name => 'TMS Extended Sender',
    :worker => Odm::TMS_EXTENDED_WORKER)

email_loopback = EmailVendor.find_or_create_by_name!(
    :name => 'Email Loopback Sender',
    :worker => 'LoopbackEmailWorker')

if Rails.env.development? || Rails.env.ci?
  #
  # This is just stuff for DEVELOPMENT purposes
  #
  # $ USE_TWILIO=true rake db:seed
  #   if you want to really connect to twilio, set USE_TWILIO=true; otherwise
  #   the seeds will load with loopback vendors.
  #

  omg = if (ENV['USE_TWILIO'] == 'true')
          puts "** using Twilio and ODM senders for default account **"
          Account.find_or_initialize_by_name(voice_vendor: twilio_voice_sender,
                                             sms_vendor:   twilio_sms_sender,
                                             email_vendor: odm_sender,
                                             name:         "OMG")
        else
          puts "**  using loopback senders for default account   **"
          puts "** run with USE_TWILIO=true to use Twilio/ODM senders **"
          Account.find_or_initialize_by_name(:voice_vendor => voice_loopback,
                                             :sms_vendor   => sms_loopback,
                                             :email_vendor => email_loopback,
                                             :name         => "OMG")
        end
  omg.from_addresses.build(:from_email => 'tms_dev@evotest.govdelivery.com',
                           :errors_to => 'errors@evotest.govdelivery.com',
                           :reply_to => 'reply@evotest.govdelivery.com',
                           :is_default => true)
  omg.save!

  # stop requests to this account will spray out to DCM accounts ACME and VANDELAY
  omg.dcm_account_codes = Set.new(['ACME', 'VANDELAY'])
  omg.save!
  omg.add_command!(:params => CommandParameters.new(:dcm_account_codes => ['ACME', 'VANDELAY']), :command_type => :dcm_unsubscribe)

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

  # Respond to "DONKEY" with "hee-haw!"
  kw = Keyword.new(:name => "DONKEY", :response_text => "hee-haw!")
  kw.account = omg
  kw.vendor = omg.sms_vendor
  kw.save!
  
  # Make the product user (admin)
  user = User.find_or_create_by_email(:email => "product@govdelivery.com", :password => "retek01!")
  user.account = omg
  user.admin = true
  user.save!

elsif Account.count == 0 && User.count ==0
  puts "#{Rails.env} DB looks empty, creating a GovDelivery account."
  account= Account.new(:voice_vendor => twilio_voice_sender,
                           :sms_vendor => twilio_sms_sender,
                           :email_vendor => odm_sender,
                           :name => 'GovDelivery')
  account.build_default_from_address(:from_email => 'info99@service.govdelivery.com')
  account.save!
  user = account.users.create!(:email => "product@evotest.govdelivery.com", :password => "retek01!")
  user.admin = true
  user.save!
else
  puts "#{Rails.env} already has accounts and users so I won't create any."
end
