voice = configatron.voice

case environment
  when :qc
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
  when :integration
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
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
