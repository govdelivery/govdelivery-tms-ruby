module Mblox
  class StatusWorker
    attr_accessor :recipient

    def perform(params)
      @recipient = SmsRecipient.where(ack: params['batch_id'], formatted_phone: PhoneNumber.new(params['recipient']).e164).first!
      if (transition = transition_for(params['status'], params['code']))
        @recipient.send(transition, @recipient.ack)
      end
    end

    def transition_for(status, code)
      case status
        when "Queued", "Dispatched"
          nil # noop
        when "Aborted"
          ['402', '405', '407'].include?(code.to_s) ? :retry! : :canceled!
        when "Expired"
          :retry!
        when "Delivered"
          :sent!
        when "Failed", "Rejected"
          :failed!
        when "Unknown"
          :inconclusive!
        else
          raise StandardError.new("Invalid delivery state")
      end
    end
  end
end
