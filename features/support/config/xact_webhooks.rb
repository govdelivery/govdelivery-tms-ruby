# Config info for the accounts that are used to test webhooks

configatron.accounts.webhooks.xact.url = configatron.xact.url
webhooks = configatron.accounts.webhooks

# Many of the webhook test account attributes are set by a rake task that is run on all environments, so most values
# are shared across environments
webhooks.xact.user.password = 'retek01!'
webhooks.xact.user.admin = true
webhooks.sms.phone.number = '+15559999999'
webhooks.sms.phone.sid = nil
webhooks.sms.vendor.username = 'loopbacks_account_sms_username'
webhooks.sms.vendor.password = 'dont care'
webhooks.sms.vendor.shared = false
webhooks.sms.vendor.twilio_test = false
webhooks.sms.prefix = nil
webhooks.voice.phone.number = '+15559999999'
webhooks.voice.phone.sid = nil
webhooks.voice.vendor.username = 'loopbacks_account_voice_username'
webhooks.voice.vendor.password = 'dont care'
webhooks.voice.twilio_test = false

case environment
  when :development
    webhooks.xact.account.id = ENV['XACT_WEBHOOK_ACCOUNT_ID']
    webhooks.xact.user.token = ENV['XACT_WEBHOOK_USER_TOKEN']
    webhooks.xact.user.email_address = 'development-loopback@govdelivery.com'
  when :qc
    webhooks.xact.account.id = '10460'
    webhooks.xact.user.token = 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL'
    webhooks.xact.user.email_address = 'qc-loopback@govdelivery.com'
  when :integration
    webhooks.xact.account.id = '10200'
    webhooks.xact.user.token = '7SxUtWmkq5Lsjnw2s5rxJULqrHs37AbE'
    webhooks.xact.user.email_address = 'int-loopback@govdelivery.com'
  when :stage
    webhooks.xact.account.id = '10862'
    webhooks.xact.user.token = 'CtyXxoinsNHujmfFd2qhKRJvDBMNqmPm'
    webhooks.xact.user.email_address = 'stage-loopback@govdelivery.com'
end
