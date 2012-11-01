# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

Vendor.create(:name => 'Twilio Sender',
  :worker => 'TwilioMessageWorker',
  :username => Rails.configuration.twilio_username,
  :password => Rails.configuration.twilio_password,
  :from => Rails.configuration.twilio_number)
loopback = Vendor.create(:name => 'Loopback Sender',
  :worker => 'LoopbackMessageWorker',
  :username => 'dont care',
  :password => 'dont care',
  :from => 'dont care')

#
# This is just stuff for DEVELOPMENT purposes
#
if Rails.env == 'development'
  acme = Account.create!(:vendor => loopback, :name => "ACME")
  user = User.new(:email => "product@govdelivery.com", :password => "retek01!")
  user.account = acme
  user.admin = true
  user.save!
  message = user.messages.create!(:short_body => "HELLO")
  ["444-555-6666", "555-666-7777"].each do |n|
    message.recipients.create!(:vendor => loopback, :phone => n)
  end
  loopback.stop_requests.create!(:phone => "+14445556666")
end