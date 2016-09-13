require 'base'
module Kahlo
  class StatusWorker
    include Workers::Base

    attr_reader :recipient

    def perform(params)
      @recipient = SmsRecipient.find(params['callback_id'])
      if (transition = transition_for(params['status']))
        @recipient.send(transition, nil, nil, params['status_message'])
      end
    rescue ActiveRecord::RecordNotFound => e
      raise Sidekiq::Retries::Fail.new(e)
    end

    def transition_for(status)
      case status
        when "new", "enqueued", "attempted"
          nil
        when "failed"
          :failed!
        when "vendor_sent", "carrier_delivered"
          :sent!
        else
          raise Sidekiq::Retries::Fail.new(nil, "Invalid delivery state: #{status}")
      end
    end
  end
end