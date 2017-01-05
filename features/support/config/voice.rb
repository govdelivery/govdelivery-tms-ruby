voice = configatron.voice

case environment
  when :qc
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
  when :integration #using creds from GovD test account main, where QC is a QC subaccount 
    # account_id: 10060
    voice.send_number = '+16515043056'
    voice.send_number_formatted = '(651) 504-3056'
    configatron.test_support.twilio.account.sid = 'AC189315456a80a4d1d4f82f4a732ad77e'
    configatron.test_support.twilio.account.token = '88e3775ad71e487c7c90b848a55a5c88'
  when :stage
    voice.send_number = '+16123459610'
    voice.send_number_formatted = '(612) 345-9610'
    configatron.test_support.twilio.account.sid = 'ACcc41a7e742457806f26d91a1ea19de9f'
    configatron.test_support.twilio.account.token = '331b3a44b5067a3c02013a6cfaa18b1c'

  # need prod account -- see support/config/tms.rb
  # when :prod
  #   voice.send_number = '+16123459610'
  #   voice.send_number_formatted = '(612) 345-9610'
end
