require 'base'
module Twilio
  class SmsPollingWorker
    include StatusPoller

    if Rails.configuration.twilio_polling_enabled
      recurrence {Rails.configuration.twilio_sms_poll_crontab}
    end

    self.service = Service::TwilioClient::Sms
    self.recipient_class = SmsRecipient
  end
end