# Config info for the accounts that are used to test sms_2way_cdc

configatron.accounts.sms_keyword_commands_forward_worker.xact.url = configatron.xact.url
sms_keyword_commands_forward_worker = configatron.accounts.sms_keyword_commands_forward_worker

# Common or default values for SMS 2Way CDC test accounts across environments
sms_keyword_commands_forward_worker.xact.user.password              = 'retek01!'
sms_keyword_commands_forward_worker.xact.user.admin                 = true

sms_keyword_commands_forward_worker.sms                             = configatron.sms_vendors.twilio_valid_test.clone
sms_keyword_commands_forward_worker.voice                           = configatron.voice_vendors.twilio_valid_test.clone
sms_keyword_commands_forward_worker.sms.prefix                      = 'sms_2way_cdc'

case environment
when :development
  sms_keyword_commands_forward_worker.xact.account.id             = ENV['XACT_SMS2WAYCDC_ACCOUNT_ID']
  sms_keyword_commands_forward_worker.xact.user.token             = ENV['XACT_SMS2WAYCDC_USER_TOKEN']
  sms_keyword_commands_forward_worker.xact.user.email_address     = 'development-sms_2way_cdc-test@govdelivery.com'
when :qc
  sms_keyword_commands_forward_worker.xact.account.id             = '10562'
  sms_keyword_commands_forward_worker.xact.user.token             = 'hSAmtjBYz8GsRhzf6Y1fsMSy6VT7YuT5'
  sms_keyword_commands_forward_worker.xact.user.email_address     = 'qc-sms_2way_cdc-test@govdelivery.com'
when :integration
  sms_keyword_commands_forward_worker.xact.account.id             = '10280'
  sms_keyword_commands_forward_worker.xact.user.token             = 'suRTbcBqpJ7WiSq6hso5AXUe8rFQA53G'
  sms_keyword_commands_forward_worker.xact.user.email_address     = 'integration-sms_2way_cdc-test@govdelivery.com'
when :stage
  sms_keyword_commands_forward_worker.xact.account.id             = '10980'
  sms_keyword_commands_forward_worker.xact.user.token             = '7rgp8b3atMtbBV4q2fYCkYfkavdq5asz'
  sms_keyword_commands_forward_worker.xact.user.email_address     = 'stage-sms_2way_cdc-test@govdelivery.com'
end
