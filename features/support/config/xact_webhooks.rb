webhooks = configatron.accounts.webhooks

case environment
when :development
  webhooks.xact.account.id = ENV['XACT_WEBHOOK_ACCOUNT_ID']
  webhooks.xact.token = ENV['XACT_WEBHOOK_USER_TOKEN']
  webhooks.xact.email_address = 'development-webhooks-test@govdelivery.com'
when :qc
  webhooks.xact.account.id = '10520'
  webhooks.xact.token = 'i38CvrkGeDypJnijfGz9zd1EUZkzctYg'
  webhooks.xact.email_address = 'qc-webhooks-test@govdelivery.com'
when :integration
  webhooks.xact.account.id = '10220'
  webhooks.xact.token = 'pnJRwcsTU59dHiNKFvRC5qZnHTq5F1nU'
  webhooks.xact.email_address = 'integration-webhooks-test@govdelivery.com'
when :stage
  webhooks.xact.account.id = '11020'
  webhooks.xact.token = 'XX298RJyjk5pnLRRDyxaBArz6ocBcCEo'
  webhooks.xact.email_address = 'stage-webhooks-test@govdelivery.com'
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
