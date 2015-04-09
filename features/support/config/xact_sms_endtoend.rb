# Config info for the accounts that are used to test sms_endtoend

configatron.accounts.sms_endtoend.xact.url = configatron.xact.url
sms_endtoend = configatron.accounts.sms_endtoend

# Common or default values for SMS End-to-End test accounts across environments
sms_endtoend.xact.user.password             = 'retek01!'
sms_endtoend.xact.user.admin                = false

sms_endtoend.sms                            = configatron.sms_vendors.live
sms_endtoend.voice                          = configatron.voice_vendors.live
sms_endtoend.sms.prefix                     = 'sms_end_to_end'

case environment
when :development
  sms_endtoend.xact.account.id            = ENV['XACT_SMSENDTOEND_ACCOUNT_ID']
  sms_endtoend.xact.user.token            = ENV['XACT_SMSENDTOEND_USER_TOKEN']
  sms_endtoend.xact.user.email_address    = 'development-sms_end_to_end-test@govdelivery.com'
when :qc
  sms_endtoend.xact.account.id            = '10524'
  sms_endtoend.xact.user.token            = 'YbYQcoszgtoyVwVRHzf8J5nq4GxDff9J'
  sms_endtoend.xact.user.email_address    = 'qc-sms_end_to_end-test@govdelivery.com'

when :integration
  sms_endtoend.xact.account.id            = '10245'
  sms_endtoend.xact.user.token            = 'e2pyzcxuEajwEmzQZxgEAQ6yxR5cMDur'
  sms_endtoend.xact.user.email_address    = 'integration-sms_end_to_end-test@govdelivery.com'

when :stage
  sms_endtoend.xact.account.id            = '10942'
  sms_endtoend.xact.user.token            = 'zyyyNEf4tTUWqqeYPzQMqkaden8CLnpy'
  sms_endtoend.xact.user.email_address    = 'stage-sms_end_to_end-test@govdelivery.com'
end
