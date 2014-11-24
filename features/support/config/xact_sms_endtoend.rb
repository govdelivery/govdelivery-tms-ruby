# Config info for the accounts that are used to test sms_endtoend

configatron.accounts.sms_endtoend.xact.url = configatron.xact.url
sms_endtoend = configatron.accounts.sms_endtoend

# Common or default values for SMS End-to-End test accounts across environments
sms_endtoend.xact.user.password             = 'retek01!'
sms_endtoend.xact.user.admin                = true

sms_endtoend.sms.vendor.username            = 'AC189315456a80a4d1d4f82f4a732ad77e'
sms_endtoend.sms.vendor.password            = '88e3775ad71e487c7c90b848a55a5c88'
sms_endtoend.sms.vendor.shared              = false
sms_endtoend.sms.vendor.twilio_test         = false
sms_endtoend.sms.prefix                     = nil

sms_endtoend.voice.phone.number             = '+15551112222'
sms_endtoend.voice.phone.sid                = nil
sms_endtoend.voice.vendor.username          = 'voice_loopback_username'
sms_endtoend.voice.vendor.password          = 'dont care'
sms_endtoend.voice.twilio_test              = false

case environment
  when :development
    sms_endtoend.xact.account.id            = ENV['XACT_SMSENDTOEND_ACCOUNT_ID']
    sms_endtoend.xact.user.token            = ENV['XACT_SMSENDTOEND_USER_TOKEN']
    sms_endtoend.xact.user.email_address    = 'development-loopback@govdelivery.com'
  when :qc
    sms_endtoend.xact.account.id            = '10120'
    sms_endtoend.xact.user.token            = 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp'
    sms_endtoend.xact.user.email_address    = 'cukeautoqc@govdelivery.com'

    sms_endtoend.sms.phone.number           = '+16519684981'
    sms_endtoend.sms.phone.sid              = 'PN732e0d02edf9e1fdd61a3606ac030e34'
  when :integration
    sms_endtoend.xact.account.id            = '10060'
    sms_endtoend.xact.user.token            = 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
    sms_endtoend.xact.user.email_address    = 'cukeautoint@govdelivery.com'

    sms_endtoend.sms.phone.number           = '+16122550428'
    sms_endtoend.sms.phone.sid              = 'PN32087052fc8c8cc15e312a70b704eef9'

    sms_endtoend.voice.phone.number         = '+19138719228'
    sms_endtoend.voice.phone.sid            = 'PN737ad7753ece587e2f2f72dd7ba5e459'

    sms_endtoend.voice.vendor.username      = 'AC189315456a80a4d1d4f82f4a732ad77e'
    sms_endtoend.voice.vendor.password      = '88e3775ad71e487c7c90b848a55a5c88'
  when :stage
    sms_endtoend.xact.account.id            = '10360'
    sms_endtoend.xact.user.token            = 'd6pAps9Xw3gqf6yxreHbwonpmb9JywV3'
    sms_endtoend.xact.user.email_address    = 'cukestage@govdelivery.com'

    sms_endtoend.sms.phone.number           = '+16124247727'
    sms_endtoend.sms.sid                    = 'PNe896243b192ff04674538f3aa11ea839'

    sms_endtoend.voice.phone.number         = '+16514336311'
    sms_endtoend.voice.phone.sid            = 'PN06416578aa730a3e8f0fd3865ce9c458'

    sms_endtoend.voice.vendor.username      = 'ACcc41a7e742457806f26d91a1ea19de9f'
    sms_endtoend.voice.vendor.password      = '331b3a44b5067a3c02013a6cfaa18b1c'
end
