# Config info for the accounts that are used to test webhooks

configatron.accounts.webhooks.xact.url = configatron.xact.url
webhooks = configatron.accounts.webhooks

# Set common values across environments, most based on config values for shared vendors
webhooks.xact.user.password = 'retek01!'
webhooks.xact.user.admin = false

webhooks.sms = configatron.sms_vendors.loopback.clone
webhooks.voice = configatron.voice_vendors.loopback.clone
webhooks.sms.prefix = 'webhooks'

case environment
when :development
  webhooks.xact.account.id = ENV['XACT_WEBHOOK_ACCOUNT_ID']
  webhooks.xact.user.token = ENV['XACT_WEBHOOK_USER_TOKEN']
  webhooks.xact.user.email_address = 'development-webhooks-test@govdelivery.com'
when :qc
  webhooks.xact.account.id = '10520'
  webhooks.xact.user.token = 'i38CvrkGeDypJnijfGz9zd1EUZkzctYg'
  webhooks.xact.user.email_address = 'qc-webhooks-test@govdelivery.com'
when :integration
  webhooks.xact.account.id = '10220'
  webhooks.xact.user.token = 'pnJRwcsTU59dHiNKFvRC5qZnHTq5F1nU'
  webhooks.xact.user.email_address = 'integration-webhooks-test@govdelivery.com'
when :stage
  webhooks.xact.account.id = '11020'
  webhooks.xact.user.token = 'XX298RJyjk5pnLRRDyxaBArz6ocBcCEo'
  webhooks.xact.user.email_address = 'stage-webhooks-test@govdelivery.com'
end

webhooks.magic.email.sending = 'sending@sink.govdelivery.com'
webhooks.magic.email.sent = 'sent@sink.govdelivery.com'
webhooks.magic.email.failed = 'failed@sink.govdelivery.com'
webhooks.magic.email.blacklisted = 'blacklisted@sink.govdelivery.com'
webhooks.magic.email.inconclusive = 'inconclusive@sink.govdelivery.com'
webhooks.magic.email.canceled = 'canceled@sink.govdelivery.com'

webhooks.magic.phone.sending = '15005550001'
webhooks.magic.phone.inconclusive = '15005550002'
webhooks.magic.phone.canceled = '15005550003'
webhooks.magic.phone.failed = '15005550004'
webhooks.magic.phone.blacklisted = '15005550005'
webhooks.magic.phone.sent = '15005550006'
