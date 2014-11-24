# Config info for the accounts that are used to test email_endtoend

configatron.accounts.email_endtoend.xact.url = configatron.xact.url
email_endtoend = configatron.accounts.email_endtoend

# Common or default values for Email End-to-End test accounts across environments
email_endtoend.xact.user.password             = 'govdel01'
email_endtoend.xact.user.admin                = true

email_endtoend.sms.vendor.username            = 'AC189315456a80a4d1d4f82f4a732ad77e'
email_endtoend.sms.vendor.password            = '88e3775ad71e487c7c90b848a55a5c88'
email_endtoend.sms.vendor.shared              = false
email_endtoend.sms.vendor.twilio_test         = false
email_endtoend.sms.prefix                     = nil

email_endtoend.voice.phone.number             = '+15551112222'
email_endtoend.voice.phone.sid                = nil
email_endtoend.voice.vendor.username          = 'voice_loopback_username'
email_endtoend.voice.vendor.password          = 'dont care'
email_endtoend.voice.twilio_test              = false

email_endtoend.gmail.imap.address             = 'imap.gmail.com'
email_endtoend.gmail.imap.port                = 993
email_endtoend.gmail.imap.password            = 'govdel01!'
email_endtoend.gmail.imap.enable_ssl          = true

case environment
  when :development
    email_endtoend.xact.account.id            = ENV['XACT_EMAILENDTOEND_ACCOUNT_ID']
    email_endtoend.xact.user.token            = ENV['XACT_EMAILENDTOEND_USER_TOKEN']
    email_endtoend.xact.user.email_address    = 'development-loopback@govdelivery.com'

  when :qc
    email_endtoend.xact.account.id            = '10120'
    email_endtoend.xact.user.token            = 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp'
    email_endtoend.xact.user.email_address    = 'cukeautoqc@govdelivery.com'

    email_endtoend.sms.phone.number           = '+16519684981'
    email_endtoend.sms.phone.sid              = 'PN732e0d02edf9e1fdd61a3606ac030e34'

    email_endtoend.gmail.imap.user_name       = 'canari11dd@gmail.com'

  when :integration
    email_endtoend.xact.account.id            = '10060'
    email_endtoend.xact.user.token            = 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
    email_endtoend.xact.user.email_address    = 'cukeautoint@govdelivery.com'

    email_endtoend.sms.phone.number           = '+16122550428'
    email_endtoend.sms.phone.sid              = 'PN32087052fc8c8cc15e312a70b704eef9'

    email_endtoend.voice.phone.number         = '+19138719228'
    email_endtoend.voice.phone.sid            = 'PN737ad7753ece587e2f2f72dd7ba5e459'

    email_endtoend.voice.vendor.username      = 'AC189315456a80a4d1d4f82f4a732ad77e'
    email_endtoend.voice.vendor.password      = '88e3775ad71e487c7c90b848a55a5c88'

    email_endtoend.gmail.imap.user_name       = 'canari9dd@gmail.com'

  when :stage
    email_endtoend.xact.account.id            = '10360'
    email_endtoend.xact.user.token            = 'd6pAps9Xw3gqf6yxreHbwonpmb9JywV3'
    email_endtoend.xact.user.email_address    = 'cukestage@govdelivery.com'

    email_endtoend.sms.phone.number           = '+16124247727'
    email_endtoend.sms.sid                    = 'PNe896243b192ff04674538f3aa11ea839'

    email_endtoend.voice.phone.number         = '+16514336311'
    email_endtoend.voice.phone.sid            = 'PN06416578aa730a3e8f0fd3865ce9c458'

    email_endtoend.voice.vendor.username      = 'ACcc41a7e742457806f26d91a1ea19de9f'
    email_endtoend.voice.vendor.password      = '331b3a44b5067a3c02013a6cfaa18b1c'

    email_endtoend.gmail.imap.user_name       = 'canari7dd@gmail.com'

  when :prod
    email_endtoend.xact.user.emil_address     = 'CUKEPROD@govdelivery.com'
    email_endtoend.xact.user.password         = 'GovDel01'

    email_endtoend.gmail.imap.user_name       = 'canari8dd@gmail.com'
end
