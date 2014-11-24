# Config info for the accounts that are used to test sms_2way_bart

configatron.accounts.sms_2way_bart.xact.url = configatron.xact.url
sms_2way_bart = configatron.accounts.sms_2way_bart

# This is using the same XACT Account as the Webhooks Test

# Common or default values for SMS 2Way Static Response test accounts across environments
sms_2way_bart.xact.user.password              = 'retek01!'
sms_2way_bart.xact.user.admin                 = true
sms_2way_bart.sms.phone.number                = '+15559999999'
sms_2way_bart.sms.phone.sid                   = nil
sms_2way_bart.sms.vendor.username             = 'loopbacks_account_sms_username'
sms_2way_bart.sms.vendor.password             = 'dont care'
sms_2way_bart.sms.vendor.shared               = false
sms_2way_bart.sms.vendor.twilio_test          = false
sms_2way_bart.sms.prefix                      = nil
sms_2way_bart.voice.phone.number              = '+15559999999'
sms_2way_bart.voice.phone.sid                 = nil
sms_2way_bart.voice.vendor.username           = 'loopbacks_account_voice_username'
sms_2way_bart.voice.vendor.password           = 'dont care'
sms_2way_bart.voice.twilio_test               = false

case environment
  when :development
    sms_2way_bart.xact.account.id             = ENV['XACT_SMS2WAYBART_ACCOUNT_ID']
    sms_2way_bart.xact.user.token             = ENV['XACT_SMS2WAYBART_USER_TOKEN']
    sms_2way_bart.xact.user.email_address     = 'development-loopback@govdelivery.com'
  when :qc
    sms_2way_bart.xact.account.id             = '10460'
    sms_2way_bart.xact.user.token             = 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL'
    sms_2way_bart.xact.user.email_address     = 'qc-loopback@govdelivery.com'
  when :integration
    sms_2way_bart.xact.account.id             = '10200'
    sms_2way_bart.xact.user.token             = '7SxUtWmkq5Lsjnw2s5rxJULqrHs37AbE'
    sms_2way_bart.xact.user.email_address     = 'int-loopback@govdelivery.com'
  when :stage
    sms_2way_bart.xact.account.id             = '10862'
    sms_2way_bart.xact.user.token             = 'CtyXxoinsNHujmfFd2qhKRJvDBMNqmPm'
    sms_2way_bart.xact.user.email_address     = 'stage-loopback@govdelivery.com'
end
