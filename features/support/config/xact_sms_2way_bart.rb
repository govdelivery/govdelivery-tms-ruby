# Config info for the accounts that are used to test sms_2way_bart

configatron.accounts.sms_2way_bart.xact.url = configatron.xact.url
sms_2way_bart = configatron.accounts.sms_2way_bart

# This is using the same XACT Account as the Webhooks Test

# Common or default values for SMS 2Way Static Response test accounts across environments
sms_2way_bart.xact.user.password              = 'retek01!'
sms_2way_bart.xact.user.admin                 = true

sms_2way_bart.sms                             = configatron.sms_vendor.loopback.clone()
sms_2way_bart.voice                           = configatron.voice_vendor.loopback.clone()
sms_2way_bart.sms.prefix                      = 'sms_2way_bart'

case environment
  when :development
    sms_2way_bart.xact.account.id             = ENV['XACT_SMS2WAYBART_ACCOUNT_ID']
    sms_2way_bart.xact.user.token             = ENV['XACT_SMS2WAYBART_USER_TOKEN']
    sms_2way_bart.xact.user.email_address     = 'development-sms_2way_bart-test@govdelivery.com'
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
