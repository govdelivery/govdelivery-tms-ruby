# Config info for the accounts that are used to test sms_2way_static

configatron.accounts.sms_2way_static.xact.url = configatron.xact.url
sms_2way_static = configatron.accounts.sms_2way_static

# This is using the same XACT Account as the Webhooks Test

# Common or default values for SMS 2Way Static Response test accounts across environments
sms_2way_static.xact.user.password              = 'retek01!'
sms_2way_static.xact.user.admin                 = true
sms_2way_static.sms.phone.number                = '+15559999999'
sms_2way_static.sms.phone.sid                   = nil
sms_2way_static.sms.vendor.username             = 'loopbacks_account_sms_username'
sms_2way_static.sms.vendor.password             = 'dont care'
sms_2way_static.sms.vendor.shared               = false
sms_2way_static.sms.vendor.twilio_test          = false
sms_2way_static.sms.prefix                      = nil
sms_2way_static.voice.phone.number              = '+15559999999'
sms_2way_static.voice.phone.sid                 = nil
sms_2way_static.voice.vendor.username           = 'loopbacks_account_voice_username'
sms_2way_static.voice.vendor.password           = 'dont care'
sms_2way_static.voice.twilio_test               = false

case environment
  when :development
    sms_2way_static.xact.account.id             = ENV['XACT_SMS2WAYSTATIC_ACCOUNT_ID']
    sms_2way_static.xact.user.token             = ENV['XACT_SMS2WAYSTATIC_USER_TOKEN']
    sms_2way_static.xact.user.email_address     = 'development-loopback@govdelivery.com'
  when :qc
    sms_2way_static.xact.account.id             = '10460'
    sms_2way_static.xact.user.token             = 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL'
    sms_2way_static.xact.user.email_address     = 'qc-loopback@govdelivery.com'
  when :integration
    sms_2way_static.xact.account.id             = '10200'
    sms_2way_static.xact.user.token             = '7SxUtWmkq5Lsjnw2s5rxJULqrHs37AbE'
    sms_2way_static.xact.user.email_address     = 'int-loopback@govdelivery.com'
  when :stage
    sms_2way_static.xact.account.id             = '10862'
    sms_2way_static.xact.user.token             = 'CtyXxoinsNHujmfFd2qhKRJvDBMNqmPm'
    sms_2way_static.xact.user.email_address     = 'stage-loopback@govdelivery.com'
end
