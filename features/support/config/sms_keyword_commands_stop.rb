# Config info for the accounts that are used to test sms_2way_stop

configatron.accounts.sms_keyword_commands_stop.xact.url = configatron.xact.url
sms_keyword_commands_stop = configatron.accounts.sms_keyword_commands_stop

# Common or default values for SMS 2way Subscribe test accounts across environments
sms_keyword_commands_stop.xact.user.password             = 'retek01!'
sms_keyword_commands_stop.xact.user.admin                = false

sms_keyword_commands_stop.sms                            = configatron.sms_vendors.twilio_valid_test.clone
sms_keyword_commands_stop.voice                          = configatron.voice_vendors.loopbacks.clone
sms_keyword_commands_stop.sms.prefix                     = 'sms_2way_stop'

case environment
when :development
  sms_keyword_commands_stop.xact.account.id            = ENV['XACT_SMS2WAYSTOP_ACCOUNT_ID']
  sms_keyword_commands_stop.xact.user.token            = ENV['XACT_SMS2WAYSTOP_USER_TOKEN']
  sms_keyword_commands_stop.xact.user.email_address    = 'development-sms_2way_stop-test@govdelivery.com'
when :qc
  sms_keyword_commands_stop.xact.account.id               = '10542'
  sms_keyword_commands_stop.xact.account.dcm_account_id   = ['CUKEAUTO_QC']
  sms_keyword_commands_stop.xact.account.dcm_topic_codes  = ['CUKEAUTO_QC_SMS']
  sms_keyword_commands_stop.xact.user.token               = 'oxyyRazrUSiUU7eyMkhwf5yDMmUCuFRq'
  sms_keyword_commands_stop.xact.user.email_address       = 'qc-sms_2way_stop-test@govdelivery.com'

when :integration
  sms_keyword_commands_stop.xact.account.id               = '10244'
  sms_keyword_commands_stop.xact.account.dcm_account_id   = ['CUKEAUTO_INT']
  sms_keyword_commands_stop.xact.account.dcm_topic_codes  = ['CUKEAUTO_INT_SMS']
  sms_keyword_commands_stop.xact.user.token               = 'UpsxeBZ744xxqyAgZR8yZPZukeciycxr'
  sms_keyword_commands_stop.xact.user.email_address       = 'integration-sms_2way_stop-test@govdelivery.com'

when :stage
  sms_keyword_commands_stop.xact.account.id               = '10943'
  sms_keyword_commands_stop.xact.account.dcm_account_id   = ['CUKEAUTO_STAGE']
  sms_keyword_commands_stop.xact.account.dcm_topic_codes  = ['CUKEAUTO_STAGE_SMS']
  sms_keyword_commands_stop.xact.user.token               = 'szk9haJyp9t1unyV4o6qpnxxhwSs3s3z'
  sms_keyword_commands_stop.xact.user.email_address       = 'stage-sms_2way_stop-test@govdelivery.com'
end
