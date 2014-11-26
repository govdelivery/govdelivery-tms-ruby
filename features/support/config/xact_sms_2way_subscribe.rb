# Config info for the accounts that are used to test sms_2way_subscribe

configatron.accounts.sms_2way_subscribe.xact.url = configatron.xact.url
sms_2way_subscribe = configatron.accounts.sms_2way_subscribe

# Common or default values for SMS 2way Subscribe test accounts across environments
sms_2way_subscribe.xact.user.password             = 'retek01!'
sms_2way_subscribe.xact.user.admin                = true

sms_2way_subscribe.sms                            = configatron.sms_vendors.twilio_valid_test.clone()
sms_2way_subscribe.voice                          = configatron.voice_vendors.loopbacks.clone()
sms_2way_subscribe.sms.prefix                     = 'sms_2way_subscribe'

case environment
  when :development
    sms_2way_subscribe.xact.account.id            = ENV['XACT_SMS2WAYSUBSCRIBE_ACCOUNT_ID']
    sms_2way_subscribe.xact.user.token            = ENV['XACT_SMS2WAYSUBSCRIBE_USER_TOKEN']
    sms_2way_subscribe.xact.user.email_address    = 'development-sms_2way_subscribe-test@govdelivery.com'
  when :qc
    sms_2way_subscribe.xact.account.id            = '10523'
    sms_2way_subscribe.xact.user.token            = 'W2jqxqpvdLAdZsPyzHN1pAryUuqCtTwP'
    sms_2way_subscribe.xact.user.email_address    = 'qc-sms_2way_subscribe-test@govdelivery.com'

  when :integration
    sms_2way_subscribe.xact.account.id            = '10244'
    sms_2way_subscribe.xact.user.token            = 'NqLbTzzWvsCXWNSzJz8yQvJwC8GrGofw'
    sms_2way_subscribe.xact.user.email_address    = 'integration-sms_2way_subscribe-test@govdelivery.com'

  when :stage
    sms_2way_subscribe.xact.account.id            = '10941'
    sms_2way_subscribe.xact.user.token            = '8wtMppgKXQxYAiqgpzF16qAWTp4oEKzZ'
    sms_2way_subscribe.xact.user.email_address    = 'stage-sms_2way_subscribe-test@govdelivery.com'
end
