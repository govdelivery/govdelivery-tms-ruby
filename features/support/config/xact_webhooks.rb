# Config info for the accounts that are used to test webhooks

configatron.accounts.webhooks.xact.url = configatron.xact.url
webhooks = configatron.accounts.webhooks

# Set common values across environments, most based on config values for shared vendors
webhooks.xact.user.password = 'retek01!'
webhooks.xact.user.admin = false

webhooks.sms = configatron.sms_vendor.loopback.clone()
webhooks.voice = configatron.voice_vendor.loopback.clone()
webhooks.sms.prefix = 'webhooks'

case environment
  when :development
    webhooks.xact.account.id = ENV['XACT_WEBHOOK_ACCOUNT_ID']
    webhooks.xact.user.token = ENV['XACT_WEBHOOK_USER_TOKEN']
    webhooks.xact.user.email_address = 'development-webhooks-test@govdelivery.com'
  when :qc
    webhooks.xact.account.id = '10460'
    webhooks.xact.user.token = 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL'
    webhooks.xact.user.email_address = 'qc-webhooks-test@govdelivery.com'
  when :integration
    webhooks.xact.account.id = '10200'
    webhooks.xact.user.token = '7SxUtWmkq5Lsjnw2s5rxJULqrHs37AbE'
    webhooks.xact.user.email_address = 'int-webhooks-test@govdelivery.com'
  when :stage
    webhooks.xact.account.id = '10862'
    webhooks.xact.user.token = 'CtyXxoinsNHujmfFd2qhKRJvDBMNqmPm'
    webhooks.xact.user.email_address = 'stage-webhooks-test@govdelivery.com'
end
