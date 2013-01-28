module Service
  class TwilioMessageService
    attr_reader :delivery_mechanism

    def initialize(delivery_mechanism)
      @delivery_mechanism = delivery_mechanism
    end

    def deliver!(message, callback_url=nil, message_url=nil)
      message.process_blacklist!
      counts = do_deliver(message, callback_url, message_url)
      complete_message!(message, counts)
    end

    private

    def do_deliver(message, callback_url, message_url=nil)
      err_count, total, success_count = 0, 0, 0
      message.sendable_recipients.find_each do |recipient|
        logger.debug("Sending message to #{recipient.phone}")
        begin
          response = delivery_mechanism.create(message, recipient, callback_url, message_url)
          logger.info("Response from Twilio was #{response.inspect}")
          complete_recipient!(recipient, response)
          success_count += 1
        rescue Twilio::REST::RequestError => e
          err_count += 1
          logger.warn("Failed to send #{message} to #{recipient.phone}: #{e.inspect}")
          complete_recipient_with_error!(recipient, e.to_s)
        ensure
          total += 1
        end
      end
      {:errors => err_count, :successes => success_count, :total => total}
    end

    def complete_recipient_with_error!(recipient, error_message)
      recipient.complete!(:error_message=>error_message)
    end

    def complete_recipient!(recipient, response)
      unless response.nil?
        status = case response.status
          when 'queued', 'sending', 'ringing', 'in-progress', 'busy', 'no-answer'
            RecipientStatus::SENDING
          when 'sent', 'completed'
            RecipientStatus::SENT
          when 'failed'
            RecipientStatus::FAILED
          when 'canceled'
            RecipientStatus::CANCELED
          else
            RecipientStatus::NEW
        end
      end
      recipient.complete!(:ack=> response.sid, :status=>status)
    end

    def complete_message!(message, counts)
      if counts[:successes] == counts[:total]
        message.complete!
      elsif counts[:errors] == counts[:total]
        message.failed!
      else
        message.sending!
      end
    end

    def logger
      @logger ||= Rails.logger
    end
  end
end