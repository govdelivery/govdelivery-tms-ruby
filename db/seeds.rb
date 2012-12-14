# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

twilio_sender = Vendor.find_by_name('Twilio Sender') || Vendor.create!(:name => 'Twilio Sender',
  :worker => 'TwilioMessageWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
sms_loopback = Vendor.find_by_name('Loopback SMS Sender') || Vendor.create!(:name => 'Loopback SMS Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => 'dont care')
voice_loopback = Vendor.find_by_name('Loopback Voice Sender') || Vendor.create!(:name => 'Loopback Voice Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => 'dont care',
  :voice => true)

#
# This is just stuff for DEVELOPMENT purposes
#
if Rails.env.development?
  omg = Account.create!(:vendors => [sms_loopback, voice_loopback], :name => "OMG")
  # stop requests to this account will spray out to DCM accounts ACME and VANDELAY
  omg.add_action!(:params => "ACME,VANDELAY", :action_type => Action::DCM_UNSUBSCRIBE)
  user = User.find_or_create_by_email(:email => "product@govdelivery.com", :password => "retek01!")
  user.account = omg
  user.admin = true
  user.save!
end
