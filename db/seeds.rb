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

raise "TWILIO_SID not set" unless twilio_username = ENV['TWILIO_SID'].try(:dup)
raise "TWILIO_TOKEN not set" unless twilio_password = ENV['TWILIO_TOKEN'].try(:dup)
raise "TWILIO_NUMBER not set" unless twilio_number = ENV['TWILIO_NUMBER'].try(:dup)
raise "TWILIO_TEST_SID not set" unless twilio_test_username = ENV['TWILIO_TEST_SID'].try(:dup)
raise "TWILIO_TEST_TOKEN not set" unless twilio_test_password = ENV['TWILIO_TEST_TOKEN'].try(:dup)

twilio_sms_sender = SmsVendor.find_or_initialize_by(name: 'Twilio Sender')
twilio_sms_sender.update_attributes(
  worker:   'TwilioMessageWorker',
  username: twilio_username,
  password: twilio_password,
  from:     twilio_number)

twilio_sms_test_sender = SmsVendor.find_or_initialize_by(name: 'Twilio Test SMS Sender')
twilio_sms_test_sender.update_attributes(
  worker:   'TwilioMessageWorker',
  username: twilio_test_username,
  password: twilio_test_password,
  from:     '+15005550006')

twilio_voice_sender = VoiceVendor.find_or_initialize_by(name: 'Twilio Voice Sender')
twilio_voice_sender.update_attributes(
  worker:   'TwilioVoiceWorker',
  username: twilio_username,
  password: twilio_password)
#  from:     twilio_number)

twilio_voice_test_sender = VoiceVendor.find_or_initialize_by(name: 'Twilio Test Voice Sender')
twilio_voice_test_sender.update_attributes(
  worker:   'TwilioVoiceWorker',
  username: twilio_test_username,
  password: twilio_test_password)
#  from:     '+15005550006')

sms_loopback = SmsVendor.find_or_initialize_by(name: 'Loopback SMS Sender')
sms_loopback.update_attributes(
                                                 worker: 'LoopbackSmsWorker',
                                                 username: 'sms_loopback_username',
                                                 password: 'dont care',
                                                 from: '+15551112222')
voice_loopback = VoiceVendor.find_or_initialize_by(name: 'Loopback Voice Sender')
voice_loopback.update_attributes(
                                                     worker: 'LoopbackVoiceWorker',
                                                     username: 'voice_loopback_username',
                                                     password: 'dont care')


odm_sender = EmailVendor.find_or_initialize_by(
    name: 'TMS Extended Sender')
odm_sender.update_attributes(
    worker: Odm::TMS_EXTENDED_WORKER)

email_loopback = EmailVendor.find_or_initialize_by(
    name: 'Email Loopback Sender')
email_loopback.update_attributes(
    worker: 'LoopbackEmailWorker')

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
          Account.find_or_initialize_by(name: "OMG") do |account|
            account.voice_vendor = twilio_voice_sender
            account.sms_vendor = twilio_sms_sender
            account.email_vendor = odm_sender
          end.tap do |a|
            a.from_numbers.build(is_default: true, phone_number: twilio_number) unless a.default_from_number
          end
        else
          puts "**  using loopback senders for default account   **"
          puts "** run with USE_TWILIO=true to use Twilio/ODM senders **"
          Account.find_or_initialize_by(name: "OMG") do |account|
            account.voice_vendor = voice_loopback
            account.sms_vendor   = sms_loopback
            account.email_vendor = email_loopback
          end.tap do |a|
            a.from_numbers.build(is_default: true, phone_number: '+15005551234') unless a.default_from_number
          end
        end
  omg.from_addresses.build(from_email: 'tms_dev@evotest.govdelivery.com',
                         errors_to:  'errors@evotest.govdelivery.com',
                         reply_to:   'reply@evotest.govdelivery.com',
                         is_default: true) unless omg.default_from_address

  # stop requests to this account will spray out to DCM accounts ACME and VANDELAY
  omg.dcm_account_codes = Set.new(['ACME', 'VANDELAY'])
  omg.save!
  omg.create_command!('stop', params: CommandParameters.new(dcm_account_codes: ['ACME', 'VANDELAY']), command_type: :dcm_unsubscribe)

  # SERVICES FOO => POST to http://localhost/forward
  kw = omg.keywords.with_name('SERVICES').first_or_create!(name: 'SERVICES')
  kw.create_command!(params: CommandParameters.new(
    username: "example@evotest.govdelivery.com",
    password: "password",
    url: "http://localhost/forward",
    http_method: "POST",
    sms_body_param_name: "sms_body1"), command_type: :forward) unless kw.commands.any?

  # SUBSCRIBE ANTHRAX => evolution API request to localhost:3001
  kw = omg.keywords.with_name('SUBSCRIBE').first_or_create!(name: 'SUBSCRIBE')
  kw.create_command!(params: CommandParameters.new(dcm_account_code: "ACME", dcm_topic_codes: ['ANTRHAX']), command_type: :dcm_subscribe) unless kw.commands.any?

  # Respond to "DONKEY" with "hee-haw!"
  kw = omg.keywords.with_name('DONKEY').first_or_create!(name: 'DONKEY', response_text: "hee-haw!")

  # Make the product user (admin)
  user = omg.users.find_or_initialize_by(email: "product@govdelivery.com") do |u|
    u.password="retek01!"
    u.admin = true
  end
  user.save!
  puts "product's token: #{user.authentication_tokens.first.token}"

elsif Account.count == 0 && User.count ==0
  puts "#{Rails.env} DB looks empty, creating a GovDelivery account."
  account= Account.new(voice_vendor: twilio_voice_sender,
                           sms_vendor: twilio_sms_sender,
                           email_vendor: odm_sender,
                           name: 'GovDelivery')
  account.from_addresses.build(is_default: true, from_email: 'info99@service.govdelivery.com')
  account.from_numbers.build(is_default: true, phone_number: twilio_number)
  account.save!
  user = account.users.create!(email: "product@evotest.govdelivery.com", password: "retek01!")
  user.admin = true
  user.save!
else
  puts "#{Rails.env} already has accounts and users so I won't create any."
end
