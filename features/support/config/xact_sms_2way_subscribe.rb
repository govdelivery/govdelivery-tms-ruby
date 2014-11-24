# Config info for the accounts that are used to test sms_2way_subscribe

configatron.accounts.sms_2way_subscribe.xact.url = configatron.xact.url
sms_2way_subscribe = configatron.accounts.sms_2way_subscribe

# Common or default values for SMS 2way Subscribe test accounts across environments
sms_2way_subscribe.xact.user.password             = 'retek01!'
sms_2way_subscribe.xact.user.admin                = true

sms_2way_subscribe.sms.vendor.username            = 'AC189315456a80a4d1d4f82f4a732ad77e'
sms_2way_subscribe.sms.vendor.password            = '88e3775ad71e487c7c90b848a55a5c88'
sms_2way_subscribe.sms.vendor.shared              = false
sms_2way_subscribe.sms.vendor.twilio_test         = false
sms_2way_subscribe.sms.prefix                     = nil

sms_2way_subscribe.voice.phone.number             = '+15551112222'
sms_2way_subscribe.voice.phone.sid                = nil
sms_2way_subscribe.voice.vendor.username          = 'voice_loopback_username'
sms_2way_subscribe.voice.vendor.password          = 'dont care'
sms_2way_subscribe.voice.twilio_test              = false

case environment
  when :development
    sms_2way_subscribe.xact.account.id            = ENV['XACT_SMS2WAYSUBSCRIBE_ACCOUNT_ID']
    sms_2way_subscribe.xact.user.token            = ENV['XACT_SMS2WAYSUBSCRIBE_USER_TOKEN']
    sms_2way_subscribe.xact.user.email_address    = 'development-loopback@govdelivery.com'
  when :qc
    sms_2way_subscribe.xact.account.id            = '10120'
    sms_2way_subscribe.xact.user.token            = 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp'
    sms_2way_subscribe.xact.user.email_address    = 'cukeautoqc@govdelivery.com'

    sms_2way_subscribe.sms.phone.number           = '+16519684981'
    sms_2way_subscribe.sms.phone.sid              = 'PN732e0d02edf9e1fdd61a3606ac030e34'
  when :integration
    sms_2way_subscribe.xact.account.id            = '10060'
    sms_2way_subscribe.xact.user.token            = 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
    sms_2way_subscribe.xact.user.email_address    = 'cukeautoint@govdelivery.com'

    sms_2way_subscribe.sms.phone.number           = '+16122550428'
    sms_2way_subscribe.sms.phone.sid              = 'PN32087052fc8c8cc15e312a70b704eef9'

    sms_2way_subscribe.voice.phone.number         = '+19138719228'
    sms_2way_subscribe.voice.phone.sid            = 'PN737ad7753ece587e2f2f72dd7ba5e459'

    sms_2way_subscribe.voice.vendor.username      = 'AC189315456a80a4d1d4f82f4a732ad77e'
    sms_2way_subscribe.voice.vendor.password      = '88e3775ad71e487c7c90b848a55a5c88'
  when :stage
    sms_2way_subscribe.xact.account.id            = '10360'
    sms_2way_subscribe.xact.user.token            = 'd6pAps9Xw3gqf6yxreHbwonpmb9JywV3'
    sms_2way_subscribe.xact.user.email_address    = 'cukestage@govdelivery.com'

    sms_2way_subscribe.sms.phone.number           = '+16124247727'
    sms_2way_subscribe.sms.sid                    = 'PNe896243b192ff04674538f3aa11ea839'

    sms_2way_subscribe.voice.phone.number         = '+16514336311'
    sms_2way_subscribe.voice.phone.sid            = 'PN06416578aa730a3e8f0fd3865ce9c458'

    sms_2way_subscribe.voice.vendor.username      = 'ACcc41a7e742457806f26d91a1ea19de9f'
    sms_2way_subscribe.voice.vendor.password      = '331b3a44b5067a3c02013a6cfaa18b1c'
end
