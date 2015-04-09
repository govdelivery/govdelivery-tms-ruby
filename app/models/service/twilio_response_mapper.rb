module Service
  class TwilioResponseMapper
    def self.recipient_callback(twilio_status)
      case twilio_status
      when 'queued', 'sending', 'ringing', 'in-progress'
        :sending!
      when 'sent', 'completed'
        :sent!
      when 'failed', 'busy', 'no-answer'
        :failed!
      when 'canceled'
        :canceled!
      else
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
