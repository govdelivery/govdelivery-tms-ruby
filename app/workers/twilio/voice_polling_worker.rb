require 'base'
module Twilio
  class VoicePollingWorker
    include StatusPoller

    if Rails.configuration.twilio_polling_enabled
      recurrence { eval(Rails.configuration.twilio_voice_poll_crontab) }
    end

    self.service = Service::TwilioClient::Voice
    self.recipient_class = VoiceRecipient
  end
end