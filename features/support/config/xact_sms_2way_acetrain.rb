# Config info for the accounts that are used to test sms_2way_acetrain

configatron.accounts.sms_2way_acetrain.xact.url = configatron.xact.url
sms_2way_acetrain = configatron.accounts.sms_2way_acetrain

# This is using the same XACT Account as the Webhooks Test

# Common or default values for SMS 2Way ACEtrain test accounts across environments
sms_2way_acetrain.xact.user.password              = 'retek01!'
sms_2way_acetrain.xact.user.admin                 = true

sms_2way_acetrain.sms                             = configatron.sms_vendors.twilio_valid_test.clone()
sms_2way_acetrain.voice                           = configatron.voice_vendors.twilio_valid_test.clone()
sms_2way_acetrain.sms.prefix                      = 'sms_2way_acetrain'

case environment
  when :development
    sms_2way_acetrain.xact.account.id             = ENV['XACT_SMS2WAYACETRAIN_ACCOUNT_ID']
    sms_2way_acetrain.xact.user.token             = ENV['XACT_SMS2WAYACETRAIN_USER_TOKEN']
    sms_2way_acetrain.xact.user.email_address     = 'development-sms_2way_acetrain-test@govdelivery.com'
  when :qc
    sms_2way_acetrain.xact.account.id             = '10525'
    sms_2way_acetrain.xact.user.token             = 'qxjKCM3a8nERHvWPHHEk8VRKhyVk9L8d'
    sms_2way_acetrain.xact.user.email_address     = 'qc-sms_2way_acetrain-test@govdelivery.com'
  when :integration
    sms_2way_acetrain.xact.account.id             = '10260'
    sms_2way_acetrain.xact.user.token             = 'TgPZDVHtXzHPemMHF9Z8sp8ZvdQEXaQr'
    sms_2way_acetrain.xact.user.email_address     = 'integration-sms_2way_acetrain-test@govdelivery.com'
  when :stage
    sms_2way_acetrain.xact.account.id             = '10960'
    sms_2way_acetrain.xact.user.token             = 'p1Hdz2W3ZGLz2n72CcBEJq6KwHFCNCye'
    sms_2way_acetrain.xact.user.email_address     = 'stage-sms_2way_acetrain-test@govdelivery.com'
end
