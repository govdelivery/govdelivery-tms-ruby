sms_keyword_commands_subscribe = configatron.accounts.sms_keyword_commands_subscribe

case environment
  when :development
    sms_keyword_commands_subscribe.xact.account.id    = ENV['XACT_SMS2WAYSUBSCRIBE_ACCOUNT_ID']
    sms_keyword_commands_subscribe.xact.token         = ENV['XACT_SMS2WAYSUBSCRIBE_USER_TOKEN']
    sms_keyword_commands_subscribe.xact.email_address = 'development-sms_2way_subscribe-test@govdelivery.com'
  when :qc
    sms_keyword_commands_subscribe.xact.account.id              = '10523'
    sms_keyword_commands_subscribe.xact.account.dcm_account_id  = 'CUKEAUTO_QC'
    sms_keyword_commands_subscribe.xact.account.dcm_topic_codes = ['CUKEAUTO_QC_SMS']
    sms_keyword_commands_subscribe.xact.token                   = 'W2jqxqpvdLAdZsPyzHN1pAryUuqCtTwP'
    sms_keyword_commands_subscribe.xact.email_address           = 'qc-sms_2way_subscribe-test@govdelivery.com'
  when :integration
    sms_keyword_commands_subscribe.xact.account.id              = '10244'
    sms_keyword_commands_subscribe.xact.account.dcm_account_id  = 'CUKEAUTO_INT'
    sms_keyword_commands_subscribe.xact.account.dcm_topic_codes = ['CUKEAUTO_INT_SMS']
    sms_keyword_commands_subscribe.xact.token                   = 'NqLbTzzWvsCXWNSzJz8yQvJwC8GrGofw'
    sms_keyword_commands_subscribe.xact.email_address           = 'integration-sms_2way_subscribe-test@govdelivery.com'

  when :stage
    sms_keyword_commands_subscribe.xact.account.id              = '10941'
    sms_keyword_commands_subscribe.xact.account.dcm_account_id  = 'CUKEAUTO_STAGE'
    sms_keyword_commands_subscribe.xact.account.dcm_topic_codes = ['CUKEAUTO_STAGE_SMS']
    sms_keyword_commands_subscribe.xact.token                   = '8wtMppgKXQxYAiqgpzF16qAWTp4oEKzZ'
    sms_keyword_commands_subscribe.xact.email_address           = 'stage-sms_2way_subscribe-test@govdelivery.com'
end
