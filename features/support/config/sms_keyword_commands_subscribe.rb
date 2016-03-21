# Config info for the accounts that are used to test sms_2way_subscribe

configatron.accounts.sms_keyword_commands_subscribe.xact.url = configatron.xact.url
sms_keyword_commands_subscribe = configatron.accounts.sms_keyword_commands_subscribe

# Common or default values for SMS 2way Subscribe test accounts across environments
sms_keyword_commands_subscribe.xact.user.password             = 'retek01!'
sms_keyword_commands_subscribe.xact.user.admin                = false

sms_keyword_commands_subscribe.sms                            = configatron.sms_vendors.twilio_valid_test.clone
sms_keyword_commands_subscribe.voice                          = configatron.voice_vendors.loopbacks.clone
sms_keyword_commands_subscribe.sms.prefix                     = 'sms_2way_subscribe'

case environment
when :development
  sms_keyword_commands_subscribe.xact.account.id            = ENV['XACT_SMS2WAYSUBSCRIBE_ACCOUNT_ID']
  sms_keyword_commands_subscribe.xact.user.token            = ENV['XACT_SMS2WAYSUBSCRIBE_USER_TOKEN']
  sms_keyword_commands_subscribe.xact.user.email_address    = 'development-sms_2way_subscribe-test@govdelivery.com'
when :qc
  sms_keyword_commands_subscribe.xact.account.id              = '10523'
  sms_keyword_commands_subscribe.xact.account.dcm_account_id  = 'CUKEAUTO_QC'
  sms_keyword_commands_subscribe.xact.account.dcm_topic_codes = ['CUKEAUTO_QC_SMS']
  sms_keyword_commands_subscribe.xact.user.token              = 'W2jqxqpvdLAdZsPyzHN1pAryUuqCtTwP'
  sms_keyword_commands_subscribe.xact.user.email_address      = 'qc-sms_2way_subscribe-test@govdelivery.com'

when :integration
  sms_keyword_commands_subscribe.xact.account.id              = '10244'
  sms_keyword_commands_subscribe.xact.account.dcm_account_id  = 'CUKEAUTO_INT'
  sms_keyword_commands_subscribe.xact.account.dcm_topic_codes = ['CUKEAUTO_INT_SMS']
  sms_keyword_commands_subscribe.xact.user.token              = 'NqLbTzzWvsCXWNSzJz8yQvJwC8GrGofw'
  sms_keyword_commands_subscribe.xact.user.email_address      = 'integration-sms_2way_subscribe-test@govdelivery.com'

when :stage
  sms_keyword_commands_subscribe.xact.account.id              = '10941'
  sms_keyword_commands_subscribe.xact.account.dcm_account_id  = 'CUKEAUTO_STAGE'
  sms_keyword_commands_subscribe.xact.account.dcm_topic_codes = ['CUKEAUTO_STAGE_SMS']
  sms_keyword_commands_subscribe.xact.user.token              = '8wtMppgKXQxYAiqgpzF16qAWTp4oEKzZ'
  sms_keyword_commands_subscribe.xact.user.email_address      = 'stage-sms_2way_subscribe-test@govdelivery.com'
end
