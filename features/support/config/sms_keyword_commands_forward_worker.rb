sms_keyword_commands_forward_worker = configatron.accounts.sms_keyword_commands_forward_worker
case environment
  when :development
    sms_keyword_commands_forward_worker.xact.account_id    = ENV['XACT_SMS2WAYCDC_ACCOUNT_ID']
    sms_keyword_commands_forward_worker.xact.token         = ENV['XACT_SMS2WAYCDC_USER_TOKEN']
    sms_keyword_commands_forward_worker.xact.email_address = 'development-sms_2way_cdc-test@govdelivery.com'
  when :qc
    sms_keyword_commands_forward_worker.xact.account_id    = '10562'
    sms_keyword_commands_forward_worker.xact.token         = 'hSAmtjBYz8GsRhzf6Y1fsMSy6VT7YuT5'
    sms_keyword_commands_forward_worker.xact.email_address = 'qc-sms_2way_cdc-test@govdelivery.com'
  when :integration
    sms_keyword_commands_forward_worker.xact.account_id    = '10280'
    sms_keyword_commands_forward_worker.xact.token         = 'suRTbcBqpJ7WiSq6hso5AXUe8rFQA53G'
    sms_keyword_commands_forward_worker.xact.email_address = 'integration-sms_2way_cdc-test@govdelivery.com'
  when :stage
    sms_keyword_commands_forward_worker.xact.account_id    = '10980'
    sms_keyword_commands_forward_worker.xact.token         = '7rgp8b3atMtbBV4q2fYCkYfkavdq5asz'
    sms_keyword_commands_forward_worker.xact.email_address = 'stage-sms_2way_cdc-test@govdelivery.com'
end
