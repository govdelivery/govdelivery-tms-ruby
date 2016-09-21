sms_keyword_commands_stop = configatron.accounts.sms_keyword_commands_stop

case environment
  when :development
    sms_keyword_commands_stop.xact.account_id    = ENV['XACT_SMS2WAYSTOP_ACCOUNT_ID']
    sms_keyword_commands_stop.xact.token         = ENV['XACT_SMS2WAYSTOP_USER_TOKEN']
    sms_keyword_commands_stop.xact.email_address = 'development-sms_2way_stop-test@govdelivery.com'
  when :qc
    sms_keyword_commands_stop.xact.account_id              = '10542'
    sms_keyword_commands_stop.xact.account.dcm_account_id  = ['CUKEAUTO_QC']
    sms_keyword_commands_stop.xact.account.dcm_topic_codes = ['CUKEAUTO_QC_SMS']
    sms_keyword_commands_stop.xact.token                   = 'oxyyRazrUSiUU7eyMkhwf5yDMmUCuFRq'
    sms_keyword_commands_stop.xact.email_address           = 'qc-sms_2way_stop-test@govdelivery.com'

  when :integration
    sms_keyword_commands_stop.xact.account_id              = '10244'
    sms_keyword_commands_stop.xact.account.dcm_account_id  = ['CUKEAUTO_INT']
    sms_keyword_commands_stop.xact.account.dcm_topic_codes = ['CUKEAUTO_INT_SMS']
    sms_keyword_commands_stop.xact.token                   = 'UpsxeBZ744xxqyAgZR8yZPZukeciycxr'
    sms_keyword_commands_stop.xact.email_address           = 'integration-sms_2way_stop-test@govdelivery.com'

  when :stage
    sms_keyword_commands_stop.xact.account_id              = '10943'
    sms_keyword_commands_stop.xact.account.dcm_account_id  = ['CUKEAUTO_STAGE']
    sms_keyword_commands_stop.xact.account.dcm_topic_codes = ['CUKEAUTO_STAGE_SMS']
    sms_keyword_commands_stop.xact.token                   = 'szk9haJyp9t1unyV4o6qpnxxhwSs3s3z'
    sms_keyword_commands_stop.xact.email_address           = 'stage-sms_2way_stop-test@govdelivery.com'
end
