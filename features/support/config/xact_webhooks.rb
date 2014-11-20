# Config info for the accounts that are used to test webhooks

# Many of the webhook test account attributes are set by a rake task that is run on all environments, so most values
# are shared across environments
cross_env = {
  :user_password => 'retek01!',
  :user_admin => true,
  :sms_phone_number => '+15559999999',
  :sms_phone_sid => nil,
  :sms_vendor_username => 'loopbacks_account_sms_username',
  :sms_vendor_password => 'dont care',
  :sms_vendor_shared => false,
  :sms_vendor_twilio_test => false,
  :sms_prefix => nil,
  :voice_phone_number => '+15559999999',
  :voice_phone_sid => nil,
  :voice_vendor_username => 'loopbacks_account_voice_username',
  :voice_vendor_password => 'dont care',
  :voice_vendor_twilio_test => false
}

configatron.accounts.webhooks.xact.url = configatron.xact.url
webhooks = configatron.accounts.webhooks

case environment
  when :development
    webhooks.xact.account.id = ENV['XACT_WEBHOOK_ACCOUNT_ID']
    webhooks.xact.user.token = ENV['XACT_WEBHOOK_USER_TOKEN']
    webhooks.xact.user.email_address = 'development-loopback@govdelivery.com'
    webhooks.xact.user.password = cross_env[:user_password]
    webhooks.xact.user.admin = cross_env[:user_admin]
    webhooks.sms.phone.number = cross_env[:sms_phone_number]
    webhooks.sms.phone.sid = cross_env[:sms_phone_sid]
    webhooks.sms.vendor.username = cross_env[:sms_vendor_username]
    webhooks.sms.vendor.password = cross_env[:sms_vendor_password]
    webhooks.sms.vendor.shared = cross_env[:sms_vendor_shared]
    webhooks.sms.vendor.twilio_test = cross_env[:sms_vendor_twilio_test]
    webhooks.sms.prefix = cross_env[:sms_prefix]
    webhooks.voice.phone.number = cross_env[:voice_phone_number]
    webhooks.voice.phone.sid = cross_env[:voice_phone_sid]
    webhooks.voice.vendor.username = cross_env[:voice_vendor_username]
    webhooks.voice.vendor.password = cross_env[:voice_vendor_password]
    webhooks.voice.twilio_test = cross_env[:voice_vendor_twilio_test]
  when :qc
    webhooks.xact.account.id = '10460'
    webhooks.xact.user.token = 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL'
    webhooks.xact.user.email_address = 'qc-loopback@govdelivery.com'
    webhooks.xact.user.password = cross_env[:user_password]
    webhooks.xact.user.admin = cross_env[:user_admin]
    webhooks.sms.phone.number = cross_env[:sms_phone_number]
    webhooks.sms.phone.sid = cross_env[:sms_phone_sid]
    webhooks.sms.vendor.username = cross_env[:sms_vendor_username]
    webhooks.sms.vendor.password = cross_env[:sms_vendor_password]
    webhooks.sms.vendor.shared = cross_env[:sms_vendor_shared]
    webhooks.sms.vendor.twilio_test = cross_env[:sms_vendor_twilio_test]
    webhooks.sms.prefix = cross_env[:sms_prefix]
    webhooks.voice.phone.number = cross_env[:voice_phone_number]
    webhooks.voice.phone.sid = cross_env[:voice_phone_sid]
    webhooks.voice.vendor.username = cross_env[:voice_vendor_username]
    webhooks.voice.vendor.password = cross_env[:voice_vendor_password]
    webhooks.voice.twilio_test = cross_env[:voice_vendor_twilio_test]
  when :integration
    webhooks.xact.account.id = '10200'
    webhooks.xact.user.token = '7SxUtWmkq5Lsjnw2s5rxJULqrHs37AbE'
    webhooks.xact.user.email_address = 'int-loopback@govdelivery.com'
    webhooks.xact.user.password = cross_env[:user_password]
    webhooks.xact.user.admin = cross_env[:user_admin]
    webhooks.sms.phone.number = cross_env[:sms_phone_number]
    webhooks.sms.phone.sid = cross_env[:sms_phone_sid]
    webhooks.sms.vendor.username = cross_env[:sms_vendor_username]
    webhooks.sms.vendor.password = cross_env[:sms_vendor_password]
    webhooks.sms.vendor.shared = cross_env[:sms_vendor_shared]
    webhooks.sms.vendor.twilio_test = cross_env[:sms_vendor_twilio_test]
    webhooks.sms.prefix = cross_env[:sms_prefix]
    webhooks.voice.phone.number = cross_env[:voice_phone_number]
    webhooks.voice.phone.sid = cross_env[:voice_phone_sid]
    webhooks.voice.vendor.username = cross_env[:voice_vendor_username]
    webhooks.voice.vendor.password = cross_env[:voice_vendor_password]
    webhooks.voice.twilio_test = cross_env[:voice_vendor_twilio_test]
  when :integration
    webhooks.xact.account.id = '10862'
    webhooks.xact.user.token = 'CtyXxoinsNHujmfFd2qhKRJvDBMNqmPm'
    webhooks.xact.user.email_address = 'stage-loopback@govdelivery.com'
    webhooks.xact.user.password = cross_env[:user_password]
    webhooks.xact.user.admin = cross_env[:user_admin]
    webhooks.sms.phone.number = cross_env[:sms_phone_number]
    webhooks.sms.phone.sid = cross_env[:sms_phone_sid]
    webhooks.sms.vendor.username = cross_env[:sms_vendor_username]
    webhooks.sms.vendor.password = cross_env[:sms_vendor_password]
    webhooks.sms.vendor.shared = cross_env[:sms_vendor_shared]
    webhooks.sms.vendor.twilio_test = cross_env[:sms_vendor_twilio_test]
    webhooks.sms.prefix = cross_env[:sms_prefix]
    webhooks.voice.phone.number = cross_env[:voice_phone_number]
    webhooks.voice.phone.sid = cross_env[:voice_phone_sid]
    webhooks.voice.vendor.username = cross_env[:voice_vendor_username]
    webhooks.voice.vendor.password = cross_env[:voice_vendor_password]
    webhooks.voice.twilio_test = cross_env[:voice_vendor_twilio_test]
end