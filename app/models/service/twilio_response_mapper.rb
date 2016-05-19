module Service
  class TwilioResponseMapper
    def self.recipient_callback(twilio_status)
      case twilio_status
      when 'accepted', 'queued', 'sending', 'ringing', 'in-progress'
        :sending!
      when 'sent', 'delivered', 'completed'
        :sent!
      when 'failed', 'busy', 'no-answer', 'undelivered'
        :failed!
      when 'canceled'
        :canceled!
      else # e.g. 'received'
        :ack!
      end
    end

    def self.secondary_status(twilio_status, answered_by)
      case twilio_status
      when 'busy', 'no-answer'
        twilio_status.underscore
      else
        answered_by
      end
    end
  end
end
