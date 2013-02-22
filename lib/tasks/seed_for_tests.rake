namespace :db do

  desc 'Seed database for testing. This creates and saves the mock data for the xact_rest_tests_followup'
  task :seed_for_tests => :environment do |t|
    all_id = 17331
    
    created_time = DateTime.new(2012, 12, 22, 10, 43, 34)
    planted_time = DateTime.new(2012, 12, 22, 11)

    omg = Account.find(10000)
    u = User.find(10000)
    sms_v = omg.sms_vendor
    voice_v = omg.voice_vendor

    sms_r = SmsRecipient.new
    sms_m = SmsMessage.new
    voice_m = VoiceMessage.new
    voice_r = VoiceRecipient.new

    sms_r.id = all_id
    sms_r.message = sms_m
    sms_r.vendor = sms_v
    sms_r.phone = "1234567890"
    sms_r.formatted_phone = "+11234567890"
    sms_r.created_at = created_time
    sms_r.completed_at = planted_time

    sms_m.id = all_id
    sms_m.body = "planted SMS Message"
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
    voice_r.phone = "1234567890"
    voice_r.formatted_phone = "+11234567890"
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

end # :db namespace
