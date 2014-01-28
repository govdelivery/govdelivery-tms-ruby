module Twilio
  class SenderWorker
    include Workers::Base

    def perform(options={})
      message = options[:message_class].constantize.find(options[:message_id])
      recipient = message.recipients.find(options[:recipient_id])
      callback_url = options[:callback_url]
      message_url = options[:message_url]

      logger.debug("Sending message to #{recipient.phone}")

      begin
        response = message.vendor.delivery_mechanism.deliver(message, recipient, callback_url, message_url)
        logger.info("Response from Twilio was #{response.inspect}")
        complete_recipient!(recipient, response.status, response.sid)
      rescue Twilio::REST::RequestError => e
        logger.warn("Failed to send #{message} to #{recipient.phone}: #{e.inspect}")
        complete_recipient_with_error!(recipient, e.to_s)
      end

    end

    def complete_recipient_with_error!(recipient, error_message)
      recipient.failed!(nil, error_message)
    end

    def complete_recipient!(recipient, status, sid)
      transition = Service::TwilioResponseMapper.recipient_callback(status)
      recipient.send(transition, sid)
    end

    def logger
      @logger ||= Sidekiq.logger
    end
  end
end