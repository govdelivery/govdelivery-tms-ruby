# Config info for the accounts that are used to test email_endtoend

configatron.accounts.email_endtoend.xact.url = configatron.xact.url
email_endtoend = configatron.accounts.email_endtoend

# Common or default values for Email End-to-End test accounts across environments
email_endtoend.xact.user.password             = 'govdel01'
email_endtoend.xact.user.admin                = false

email_endtoend.sms                             = configatron.sms_vendors.loopback.clone()
email_endtoend.voice                           = configatron.voice_vendors.loopback.clone()
email_endtoend.sms.prefix                      = 'email_end_to_end'

email_endtoend.gmail.imap.address             = 'imap.gmail.com'
email_endtoend.gmail.imap.port                = 993
email_endtoend.gmail.imap.password            = 'govdel01!'
email_endtoend.gmail.imap.enable_ssl          = true

case environment
  when :development
    email_endtoend.xact.account.id            = ENV['XACT_EMAILENDTOEND_ACCOUNT_ID']
    email_endtoend.xact.user.token            = ENV['XACT_EMAILENDTOEND_USER_TOKEN']
    email_endtoend.xact.user.email_address    = 'development-email_end_to_end-test@govdelivery.com'

  when :qc
    email_endtoend.xact.account.id            = '10120'
    email_endtoend.xact.user.token            = 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp'
    email_endtoend.xact.user.email_address    = 'cukeautoqc@govdelivery.com'

    email_endtoend.gmail.imap.user_name       = 'canari11dd@gmail.com'

  when :integration
    email_endtoend.xact.account.id            = '10060'
    email_endtoend.xact.user.token            = 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
    email_endtoend.xact.user.email_address    = 'cukeautoint@govdelivery.com'

    email_endtoend.voice.vendor.username      = 'AC189315456a80a4d1d4f82f4a732ad77e'
    email_endtoend.voice.vendor.password      = '88e3775ad71e487c7c90b848a55a5c88'

    email_endtoend.gmail.imap.user_name       = 'canari9dd@gmail.com'

  when :stage
    email_endtoend.xact.account.id            = '10360'
    email_endtoend.xact.user.token            = 'd6pAps9Xw3gqf6yxreHbwonpmb9JywV3'
    email_endtoend.xact.user.email_address    = 'cukestage@govdelivery.com'

    email_endtoend.gmail.imap.user_name       = 'canari7dd@gmail.com'

  when :prod
    email_endtoend.xact.user.emil_address     = 'CUKEPROD@govdelivery.com'
    email_endtoend.xact.user.password         = 'GovDel01'

    email_endtoend.gmail.imap.user_name       = 'canari8dd@gmail.com'
end
