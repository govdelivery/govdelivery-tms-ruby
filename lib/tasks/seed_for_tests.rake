require 'fileutils'
require 'rake_helper'

namespace :db do
  # OMG Vendors
  loopback_vendors_config = {
    sms_vendor_name: 'Loopback SMS Sender',
    voice_vendor_name: 'Loopback Voice Sender',
    email_vendor_name: 'Email Loopback Sender'
  }

  desc 'Seed database for testing. This creates and saves the mock data for the xact_rest_tests_followup'
  task seed_for_tests: :environment do |_t|
    all_id = 17_331

    created_time = Time.new(2012, 12, 22, 10, 43, 34)
    planted_time = Time.new(2012, 12, 22, 11)

    omg = Account.find(10_000)
    u = User.find(10_000)
    sms_v = omg.sms_vendor
    voice_v = omg.voice_vendor

    FileUtils.mkdir_p '/tmp/xact_smoke_test/'
    filename = '/tmp/xact_smoke_test/token.txt'
    puts "putting token in #{filename}"
    File.open(filename, 'w') do |f|
      f.puts u.authentication_tokens.first.token
    end

    sms_r = SmsRecipient.new
    sms_m = SmsMessage.new
    voice_m = VoiceMessage.new
    voice_r = VoiceRecipient.new

    sms_r.id = all_id
    sms_r.message = sms_m
    sms_r.vendor = sms_v
    sms_r.phone = '1234567890'
    sms_r.formatted_phone = '+11234567890'
    sms_r.created_at = created_time
    sms_r.completed_at = planted_time

    sms_m.id = all_id
    sms_m.body = 'planted SMS Message'
    sms_m.created_at = created_time
    sms_m.completed_at = planted_time
    sms_m.user = u
    sms_m.account = sms_m.user.account

    voice_m.id = all_id
    voice_m.play_url = 'planted.voice.message.gov'
    voice_m.created_at = created_time
    voice_m.completed_at = planted_time
    voice_m.user = u
    voice_m.account = voice_m.user.account

    voice_r.id = all_id
    voice_r.phone = '1234567890'
    voice_r.formatted_phone = '+11234567890'
    voice_r.message = voice_m
    voice_r.vendor = voice_v
    voice_r.created_at = created_time
    voice_r.completed_at = planted_time
    voice_r.sent_at = planted_time

    sms_r.message = sms_m
    sms_m.recipients.push sms_r

    voice_r.message = voice_m
    voice_m.recipients.push voice_r

    tables_to_scrub = [SmsRecipient,
                       SmsMessage,
                       VoiceRecipient,
                       VoiceMessage]

    tables_to_scrub.each do |t|
      t.delete(all_id)
    end

    things_to_save = [voice_r,
                      voice_m,
                      sms_r,
                      sms_m]

    things_to_save.each do |data|
      print data.to_s
      if data.save! != true
        puts ' failed to save!'
      else
        puts ' saved'
      end
    end
  end # :seed_for_tests task

  # Creates the OMG Account vendors
  desc 'Create all the Loopback Vendors.'
  task create_loopback_vendors: :environment do |_t|
    create_or_verify_by_name(SmsVendor, name: loopback_vendors_config[:sms_vendor_name],
                                        worker: 'LoopbackSmsWorker',
                                        username: 'sms_loopback_username',
                                        password: 'dont care',
                                        from: '+15551112222')

    create_or_verify_by_name(VoiceVendor, name: loopback_vendors_config[:voice_vendor_name],
                                          worker: 'LoopbackVoiceWorker',
                                          username: 'voice_loopback_username',
                                          password: 'dont care',
                                          from: '+15551112222')

    create_or_verify_by_name(EmailVendor, name: loopback_vendors_config[:email_vendor_name],
                                          worker: 'LoopbackEmailWorker')
  end # :create_loopback_vendors

  # Creates the Shared Loopback Testing Vendors
  desc 'Create all the shared testing loopback vendors.'
  task create_shared_loopback_vendors: :environment do |_t|
    create_or_verify_by_name(SmsVendor, name: shared_loopback_vendors_config[:sms_vendor_name],
                                        worker: 'LoopbackSmsWorker',
                                        username: 'shared_loopback_sms_username',
                                        password: 'dont care',
                                        from: '+15552287439'   # 1-555-BBushey --or-- 1-555-CatShew --or-- 1-555-BatsHey
                                      )

    create_or_verify_by_name(VoiceVendor, name: shared_loopback_vendors_config[:voice_vendor_name],
                                          worker: 'LoopbackVoiceWorker',
                                          username: 'shared_loopback_voice_username',
                                          password: 'dont care')

    create_or_verify_by_name(EmailVendor, name: shared_loopback_vendors_config[:email_vendor_name],
                                          worker: 'LoopbackEmailWorker')
  end # :create_loopback_vendors

  # Creates the Shared Twilio Valid Test Testing Vendor
  desc 'Create the Shared Twilio Valid Test Testing Vendor.'
  task create_shared_twilio_valid_test_vendor: :environment do |_t|
    sms_twil_valid_test = create_or_verify_by_name(SmsVendor,         name: shared_twilio_valid_test_vendors_config[:sms_vendor_name],
                                                                      worker: 'TwilioMessageWorker',
                                                                      username: twilio_test_credentials[:sid],
                                                                      password: twilio_test_credentials[:token],
                                                                      from: '+15005550006'   # The ONE number to send a text from that Twilio Test consideres valid: http://www.twilio.com/docs/api/rest/test-credentials
                                                  )
    sms_twil_valid_test.save!
  end # :create_shared_twilio_valid_test_vendor

  # Creates the Shared Twilio Invalid Number Test Testing Vendor
  desc 'Create the Shared Twilio Invalid Number Test Testing Vendor.'
  task create_shared_twilio_invalid_number_test_vendor: :environment do |_t|
    sms_twil_invalid_number_test = create_or_verify_by_name(SmsVendor,         name: shared_twilio_invalid_number_test_vendors_config[:sms_vendor_name],
                                                                               worker: 'TwilioMessageWorker',
                                                                               username: twilio_test_credentials[:sid],
                                                                               password: twilio_test_credentials[:token],
                                                                               from: '+15005550001'   # The ONE number to send a text from that Twilio Test consideres invalid: http://www.twilio.com/docs/api/rest/test-credentials
                                                           )
    sms_twil_invalid_number_test.save!
  end # :create_shared_twilio_invalid_number_test_vendor

  desc 'Create the Shared Live Phone Vendors.'
  task create_shared_live_phone_vendors: :environment do
    sms_live_test = create_or_verify_by_name(SmsVendor,         name: shared_live_phone_vendors_config[:sms_vendor_name],
                                                                worker: 'TwilioMessageWorker',
                                                                username: twilio_live_credentials[:sid],
                                                                password: twilio_live_credentials[:token],
                                                                from: twilio_live_numbers[Rails.env]   # Each environment has it's own live number for testing
                                            )
    sms_live_test.save!

    create_or_verify_by_name(VoiceVendor,         name: shared_live_phone_vendors_config[:voice_vendor_name],
                                                  worker: 'TwilioMessageWorker',
                                                  username: twilio_live_credentials[:sid],
                                                  password: twilio_live_credentials[:token]
                            )
  end # :create_shared_twilio_invalid_number_test_vendor
end # :db namespace
