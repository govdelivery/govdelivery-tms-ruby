module TwilioClientManager
  def default_client
    @twilio_client ||= Twilio::REST::Client.new(
      configatron.test_support.twilio.account.sid,
      configatron.test_support.twilio.account.token
    )
  end

  def voice_client
    @twilio_client ||= Twilio::REST::Client.new(
      configatron.voice.twilio.account.sid,
      configatron.voice.twilio.account.token
    )
  end

  extend self
end
