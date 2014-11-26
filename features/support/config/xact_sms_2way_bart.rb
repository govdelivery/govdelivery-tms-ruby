# Config info for the accounts that are used to test sms_2way_bart

configatron.accounts.sms_2way_bart.xact.url = configatron.xact.url
sms_2way_bart = configatron.accounts.sms_2way_bart

# This is using the same XACT Account as the Webhooks Test

# Common or default values for SMS 2Way Static Response test accounts across environments
sms_2way_bart.xact.user.password              = 'retek01!'
sms_2way_bart.xact.user.admin                 = true

sms_2way_bart.sms                             = configatron.sms_vendors.loopback.clone()
sms_2way_bart.voice                           = configatron.voice_vendors.loopback.clone()
sms_2way_bart.sms.prefix                      = 'sms_2way_bart'

case environment
  when :development
    sms_2way_bart.xact.account.id             = ENV['XACT_SMS2WAYBART_ACCOUNT_ID']
    sms_2way_bart.xact.user.token             = ENV['XACT_SMS2WAYBART_USER_TOKEN']
    sms_2way_bart.xact.user.email_address     = 'development-sms_2way_bart-test@govdelivery.com'
  when :qc
    sms_2way_bart.xact.account.id             = '10522'
    sms_2way_bart.xact.user.token             = 'SvAsc6AkCq3x6uxxcYowpg5Y8Z9VJZdc'
    sms_2way_bart.xact.user.email_address     = 'qc-sms_2way_bart-test@govdelivery.com'
  when :integration
    sms_2way_bart.xact.account.id             = '10242'
    sms_2way_bart.xact.user.token             = 'JDchCvYzmie2KLtf7q74dKezyBAaVJDx'
    sms_2way_bart.xact.user.email_address     = 'integration-sms_2way_bart-test@govdelivery.com'
  when :stage
    sms_2way_bart.xact.account.id             = '10921'
    sms_2way_bart.xact.user.token             = 'RK4nk6qCEtDxNBjx4KAtxuizz9Hityb3'
    sms_2way_bart.xact.user.email_address     = 'stage-sms_2way_bart-test@govdelivery.com'
end
