require 'base'
module Twilio
  class VoicePollingWorker
    include StatusPoller

    self.service = Service::TwilioClient::Voice
    self.recipient_class = VoiceRecipient
  end
end