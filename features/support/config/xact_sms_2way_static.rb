# Config info for the accounts that are used to test sms_2way_static

configatron.accounts.sms_2way_static.xact.url = configatron.xact.url
sms_2way_static = configatron.accounts.sms_2way_static

# This is using the same XACT Account as the Webhooks Test

# Common or default values for SMS 2Way Static Response test accounts across environments
sms_2way_static.xact.user.password              = 'retek01!'
sms_2way_static.xact.user.admin                 = false

sms_2way_static.sms                             = configatron.sms_vendors.loopback.clone
sms_2way_static.voice                           = configatron.voice_vendors.loopback.clone
sms_2way_static.sms.prefix                      = 'sms_2way_static'

case environment
when :development
  sms_2way_static.xact.account.id             = ENV['XACT_SMS2WAYSTATIC_ACCOUNT_ID']
  sms_2way_static.xact.user.token             = ENV['XACT_SMS2WAYSTATIC_USER_TOKEN']
  sms_2way_static.xact.user.email_address     = 'development-sms_2way_static-test@govdelivery.com'
when :qc
  sms_2way_static.xact.account.id             = '10521'
  sms_2way_static.xact.user.token             = 'LpJjoSXCreAXUQrjrCpL6fGePWrCrsMP'
  sms_2way_static.xact.user.email_address     = 'qc-sms_2way_static-test@govdelivery.com'
when :integration
  sms_2way_static.xact.account.id             = '10221'
  sms_2way_static.xact.user.token             = 'QFKWugoA5x4VaVxZBwqgpfwXivAy18z9'
  sms_2way_static.xact.user.email_address     = 'integration-sms_2way_static-test@govdelivery.com'
when :stage
  sms_2way_static.xact.account.id             = '11040'
  sms_2way_static.xact.user.token             = '1ToqN9B129KNkaBp8Fy3XJiuDvncnEhp'
  sms_2way_static.xact.user.email_address     = 'stage-sms_2way_static-test@govdelivery.com'
end
