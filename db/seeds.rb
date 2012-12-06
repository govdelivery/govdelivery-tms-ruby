# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

twilio_dev = Vendor.find_by_name('Twilio Dev Sender') || Vendor.create!(:name => 'Twilio Dev Sender',
  :worker => 'TwilioMessageWorker',
  :username => Rails.configuration.twilio_dev_username,
  :password => Rails.configuration.twilio_dev_password,
  :from => Rails.configuration.twilio_dev_number)
twilio_reals = Vendor.find_by_name('Twilio Sender') || Vendor.create!(:name => 'Twilio Sender',
  :worker => 'TwilioMessageWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
loopback = Vendor.find_by_name('Loopback Sender') || Vendor.create!(:name => 'Loopback Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => 'dont care')

#
# This is just stuff for DEVELOPMENT purposes
#
if Rails.env == 'development'
  omg = Account.create!(:vendors => [loopback], :name => "OMG")
  # stop requests to this account will spray out to DCM accounts ACME and VANDELAY
  omg.add_action!(:params => "ACME,VANDELAY", :action_type => Action::DCM_UNSUBSCRIBE)
  user = User.find_or_create_by_email(:email => "product@govdelivery.com", :password => "retek01!")
  user.account = omg
  user.admin = true
  user.save!
  message = user.messages.create!(:short_body => "HELLO")
  ["444-555-6666", "555-666-7777"].each do |n|
    message.recipients.create!(:vendor => loopback, :phone => n)
  end
  loopback.stop_requests.create(:phone => "+14445556666")
  
  wtf = Account.create!(:vendors => [twilio_dev], :name => "WTF")
  user1 = User.find_or_create_by_email(:email => "dev@gov-i.com", :password => "dev1234")
  user1.account = wtf
  user1.admin = true
  user1.save!
  message = user1.messages.create!(:short_body => "http://localhost/file.wav")
  ["444-555-6666", "555-666-7777"].each do |n|
    message.recipients.create!(:vendor => twilio_dev, :phone => n)
  end

  bbq = Account.create!(:vendors => [twilio_reals], :name => "BBQ")
  user2 = User.new(:email => "prod@gov-i.com", :password => "live1234")
  user2.account = bbq
  user2.admin = true
  user2.save!
end
