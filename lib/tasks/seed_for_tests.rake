require 'fileutils'

namespace :db do

  loopback_vendors_config = {
      sms_vendor_name: 'Loopback SMS Sender',
      voice_vendor_name: 'Loopback Voice Sender',
      email_vendor_name: 'Email Loopback Sender'
  }


  def create_or_verify_by_name(klass, config, pre_save = nil)
    r = klass.find_by(name: config[:name])
    if r
      puts "Verifying #{config[:name]}"
      config.each do |k,v|
        r.send("#{k}=", v)
      end
      if r.changed?
        puts "\tSetting #{r.name} to #{r.changes}"
        pre_save.call(r) if pre_save
        r.save!
      end
      puts "Verified"
    else
      r = klass.new(config)
      puts "Creating #{config[:name]}"
      pre_save.call(r) if pre_save
      r.save!
      puts "Created"
    end
    puts
    r
  end


  desc 'Seed database for testing. This creates and saves the mock data for the xact_rest_tests_followup'
  task :seed_for_tests => :environment do |t|
    all_id = 17331
    
    created_time = DateTime.new(2012, 12, 22, 10, 43, 34)
    planted_time = DateTime.new(2012, 12, 22, 11)

    omg = Account.find(10000)
    u = User.find(10000)
    sms_v = omg.sms_vendor
    voice_v = omg.voice_vendor

    FileUtils.mkdir_p '/tmp/xact_smoke_test/'
    filename = "/tmp/xact_smoke_test/token.txt"
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


  desc 'Create all the Loopback Vendors.'
  task :create_loopback_vendors => :environment do |t|

    sms_loopback = create_or_verify_by_name(SmsVendor, {
        name: loopback_vendors_config[:sms_vendor_name],
        worker: 'LoopbackSmsWorker',
        username: 'sms_loopback_username',
        password: 'dont care',
        from: '+15551112222'
      }
    )

    voice_loopback = create_or_verify_by_name(VoiceVendor,{
        name: loopback_vendors_config[:voice_vendor_name],
        worker: 'LoopbackVoiceWorker',
        username: 'voice_loopback_username',
        password: 'dont care',
        from: '+15551112222'
      }
    )

    email_loopback = create_or_verify_by_name(EmailVendor, {
        name: loopback_vendors_config[:email_vendor_name],
        worker: 'LoopbackEmailWorker'
      }
    )
  end # :create_loopback_vendors


  desc 'Create an Account that has all Loopback Vendors.'
  task :create_all_loopbacks_account => :environment do |t|

    Rake::Task['db:create_loopback_vendors'].invoke

    account_config = {
        name: Rails.env.capitalize + " Loopbacks Account",
        voice_vendor: VoiceVendor.find_by(name: loopback_vendors_config[:voice_vendor_name]),
        sms_vendor: SmsVendor.find_by(name: loopback_vendors_config[:sms_vendor_name]),
        email_vendor: EmailVendor.find_by(name: loopback_vendors_config[:email_vendor_name])
    }

    account_email_addresses_config = {
        from_email: Rails.env + '-tms_dev@evotest.govdelivery.com',
        errors_to: Rails.env + '-errors@evotest.govdelivery.com',
        reply_to: Rails.env + '-reply@evotest.govdelivery.com',
        is_default: true
    }

    user_config = {
        account_name: Rails.env.capitalize + " Loopbacks Account",
        email: Rails.env + "-loopback@govdelivery.com",
        password: "retek01!",
        admin: true
    }

    lba = create_or_verify_by_name(Account, account_config, lambda{ |lba|
      if lba.from_addresses.empty?
        puts "\tCreating #{lba.name} From Addresses"
        lba.from_addresses.build(account_email_addresses_config)
        puts "\tCreated"
      end
      }
    )

    if lba.users.empty?
      user = lba.users.build(user_config)
      user.save
      token = user.authentication_tokens.build()
      token.save
      puts "User created for #{account_config[:name]}"
      puts "\tEmail Addr:\t #{user.email}"
      puts "\tPassword:\t #{user.password}"
      puts
    end

    token = lba.users.first.authentication_tokens.first.token

    puts "Loopbacks Account User Auth Token: "
    puts "\t#{token}"
    puts
  end # :create_all_loopbacks_account

end # :db namespace
