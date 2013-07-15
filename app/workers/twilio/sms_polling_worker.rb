require 'base'
module Twilio
  class SmsPollingWorker
    include StatusPoller

    self.service = Service::TwilioClient::Sms
    self.recipient_class = SmsRecipient
  end
end