# Shared Loopback Vendors
def shared_loopback_vendors_config
  loopbacks_account_vendors_config = {
    sms_vendor_name: 'Test - Shared Loopback SMS Vendor',
    voice_vendor_name: 'Test - Shared Loopback Voice Vendor',
    email_vendor_name: 'Test - Shared Loopback Email Vendor'
  }
end

def shared_twilio_valid_test_vendors_config
  config = shared_loopback_vendors_config
  config[:sms_vendor_name] = 'Test - Shared Twilio Valid Test SMS Vendor'
  return config
end

def shared_twilio_invalid_number_test_vendors_config
  config = shared_loopback_vendors_config
  config[:sms_vendor_name] = 'Test - Shared Twilio Invalid Number Test SMS Vendor'
  return config
end

def shared_live_email_vendors_config
  config = shared_loopback_vendors_config
  case Rails.env
    when "qc"
      config[:email_vendor_name] = 'ODM Sender'
    when "integration", "stage"
      config[:email_vendor_name] = 'TMS Extended Sender'
    else
      config[:email_vendor_name] = 'Test - Shared ODM Email Vendor'
  end
  return config
end

def shared_live_phone_vendors_config
  config = shared_loopback_vendors_config
  config[:sms_vendor_name] = 'Test - Shared Live SMS Vendor'
  config[:voice_vendor_name] = 'Test - Shared Live Voice Vendor'
  return config
end

def dcm_account_id
  case Rails.env
    when "qc"
      "CUKEAUTO_QC"
    when "integration"
      "CUKEAUTO_INT"
    when "stage"
      "CUKEAUTO_STAGE"
  end
end

def dcm_topic_codes
  case Rails.env
    when "qc"
      ["CUKEAUTO_QC_SMS"]
    when "integration"
      ["CUKEAUTO_INT_SMS"]
    when "stage"
      ["CUKEAUTO_STAGE_SMS"]
  end
end

def set_record_config(r, config)
  config.each do |k,v|
    r.send("#{k}=", v)
  end
end

def create_or_verify_by_name(klass, config, pre_save = nil)
  r = klass.find_by(name: config[:name])
  if r
    puts "Verifying #{config[:name]}"
    set_record_config(r, config)
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
  return r
end

def create_test_account(test_name, account_vendors_config)
  sms_shared_vendor = SmsVendor.find_by(name: account_vendors_config[:sms_vendor_name])
  sms_prefix_str = test_name.downcase.tr(' ', '_')


  account_config = {
    name: Rails.env.capitalize + " #{test_name} Test Account",
    voice_vendor: VoiceVendor.find_by(name: account_vendors_config[:voice_vendor_name]),
    sms_vendor: sms_shared_vendor,
    email_vendor: EmailVendor.find_by(name: account_vendors_config[:email_vendor_name])
  }

  account_email_addresses_config = {
    from_email: Rails.env + "-#{test_name.downcase.tr(' ', '_')}-test@govdelivery.com",
    errors_to: Rails.env + "-#{test_name.downcase.tr(' ', '_')}-errors@govdelivery.com",
    reply_to: Rails.env + "#{test_name.downcase.tr(' ', '_')}-reply@govdelivery.com",
    is_default: true
  }

  user_config = {
    email: Rails.env + "-#{test_name.downcase.tr(' ', '_')}-test@govdelivery.com",
    password: "retek01!",
    admin: false
  }

  lba = create_or_verify_by_name(
    Account,
    account_config,
    lambda { |lba|
      if lba.from_addresses.find_by(from_email: account_email_addresses_config[:from_email]).blank?
        puts "\tCreating #{lba.name} From Addresses"
        lba.from_addresses.build(account_email_addresses_config)
        puts "\tCreated"
      end

      if lba.sms_prefixes.find_by(prefix: sms_prefix_str).blank?
        sms_prefix = lba.sms_prefixes.build(:prefix => sms_prefix_str, :sms_vendor => sms_shared_vendor)
        sms_prefix.save!
        puts "SMS Prefix created for #{account_config[:name]}: #{sms_prefix.prefix}"
      end
    }
  )
  puts "#{account_config[:name]} Account Number: #{lba.id}"

  user = lba.users.find_by(email: user_config[:email])
  if user.nil?
    user = lba.users.build(user_config)
    user.admin = user_config[:admin]
    user.save
    puts "User with email #{user_config[:email]} created for #{account_config[:name]}"
  else
    puts "User with email #{user_config[:email]} exists for #{account_config[:name]}"
    set_record_config(user, user_config)
    # encrypted_password is always considered to be changed on save
    if user.changed? && !(user.changes.keys - ["encrypted_password"]).empty?
      changes = user.changes
      changes.delete("encrypted_password")
      puts
      puts "\tSetting user with email #{user_config[:email]} to #{changes}"
      user.save!
    end
  end
  puts
  puts "\tEmail Addr:\t #{user.email}"
  puts "\tAdmin?:\t\t #{user.admin?}"
  puts "\tUser ID:\t #{user.id}"

  token = user.authentication_tokens.first.token

  puts "#{user_config[:name]} Auth Token: "
  puts "\t#{token}"
  return lba
end