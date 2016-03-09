module TwilioClientManager
  def default_client
    @twilio_client ||= Twilio::REST::Client.new(
      configatron.test_support.twilio.account.sid,
      configatron.test_support.twilio.account.token)
  end

  extend self
end