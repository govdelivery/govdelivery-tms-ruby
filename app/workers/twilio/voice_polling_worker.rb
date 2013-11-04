require 'base'
module Twilio
  class VoicePollingWorker
    include StatusPoller

    if Rails.configuration.twilio_polling_enabled
      recurrence do
        eval(Rails.configuration.twilio_sms_poll_crontab)
      end
    end

    self.service = Service::TwilioClient::Voice
    self.recipient_class = VoiceRecipient
  end
end