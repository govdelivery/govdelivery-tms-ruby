voice = configatron.voice

voice.play_urls = %w(
  http://xact-webhook-callbacks.herokuapp.com/voice/first.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/second.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/third.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/fourth.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/fifth.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/sixth.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/seventh.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/eighth.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/ninth.mp3
  http://xact-webhook-callbacks.herokuapp.com/voice/tenth.mp3
)

voice.recipient.number = '+16124679346' # Probs change this.
voice.recipient.secondary_number = '+16123145807' # Probs this too.

case environment
  when :qc
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
  when :integration
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
  when :stage
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
  when :prod
    voice.send_number = '+16515043057'
    voice.send_number_formatted = '(651) 504-3057'
end