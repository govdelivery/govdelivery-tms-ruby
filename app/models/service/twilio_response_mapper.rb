module Service
  class TwilioResponseMapper
    def self.recipient_callback(twilio_status)
      case twilio_status
        when 'queued', 'sending', 'ringing', 'in-progress', 'busy', 'no-answer'
          :sending
        when 'sent', 'completed'
          :sent!
        when 'failed'
          :failed!
        when 'canceled'
          :canceled!
        else
          :ack!
      end
    end
  end
end