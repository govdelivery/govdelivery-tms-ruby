sms_keyword_commands_static = configatron.accounts.sms_keyword_commands_static
case environment
  when :development
    raise "must set XACT_SMS2WAYSTATIC_ACCOUNT_ID and XACT_SMS2WAYSTATIC_USER_TOKEN in development mode"
    sms_keyword_commands_static.xact.account_id    = ENV['XACT_SMS2WAYSTATIC_ACCOUNT_ID']
    sms_keyword_commands_static.xact.token         = ENV['XACT_SMS2WAYSTATIC_USER_TOKEN']
    sms_keyword_commands_static.xact.email_address = 'development-sms_2way_static-test@govdelivery.com'
  when :qc
    sms_keyword_commands_static.xact.account.id    = '10521'
    sms_keyword_commands_static.xact.token         = 'LpJjoSXCreAXUQrjrCpL6fGePWrCrsMP'
    sms_keyword_commands_static.xact.email_address = 'qc-sms_2way_static-test@govdelivery.com'
  when :integration
    sms_keyword_commands_static.xact.account_id    = '10221'
    sms_keyword_commands_static.xact.token         = 'QFKWugoA5x4VaVxZBwqgpfwXivAy18z9'
    sms_keyword_commands_static.xact.email_address = 'integration-sms_2way_static-test@govdelivery.com'
  when :stage
    sms_keyword_commands_static.xact.account_id    = '11040'
    sms_keyword_commands_static.xact.token         = '1ToqN9B129KNkaBp8Fy3XJiuDvncnEhp'
    sms_keyword_commands_static.xact.email_address = 'stage-sms_2way_static-test@govdelivery.com'
end
