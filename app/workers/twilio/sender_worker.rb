# This worker actually delivers messages to Twilio
#     e.g. TwilioVoiceWorker creates a batch of n Twilio::SenderWorker jobs (one per recipient)
#
module Twilio
  class SenderWorker
    include Workers::Base
    sidekiq_options retry: 0, queue: :sender
    RETRY_CODES = [401, 404, 429, 500]

    sidekiq_retries_exhausted do |msg|
      Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      new.complete_recipient_with_error!(msg['args'].first.symbolize_keys, msg['error_message'])
    end

    def find_message_and_recipient(options)
      message   = options[:message_class].constantize.find(options[:message_id])
      recipient = message.recipients.find(options[:recipient_id])
      [message, recipient]
    end

    def perform(options={})
      begin
        options.symbolize_keys!
        callback_url               = options[:callback_url]
        message_url                = options[:message_url]
        vendor, message, recipient = nil
        retryable_connection do
          ActiveRecord::Base.connection_pool.with_connection do
            message, recipient = find_message_and_recipient(options)
            vendor             = message.vendor
          end
        end
        client = vendor.delivery_mechanism
        logger.debug {"Sending message to #{recipient.phone}"}
        response = client.deliver(message, recipient, callback_url, message_url)
      rescue Twilio::REST::RequestError => e
        raise Sidekiq::Retries::Retry.new(e) if RETRY_CODES.include?(client.last_response_code)
        logger.warn {"Non-retryable error from Twilio (#{message}): #{e.code} - #{e.message}"}
        recipient.failed!(nil, nil, e.message)
        return
      rescue StandardError => e
        raise Sidekiq::Retries::Retry.new(e)
      end

      logger.info {"Response from Twilio was #{response.inspect}"}
      begin
        self.class.complete_recipient!(recipient, response.status, response.sid)
      rescue ActiveRecord::ConnectionTimeoutError => e
        self.class.delay(retry: 10).complete_recipient!(recipient, response.status, response.sid)
        raise e
      end
    end

    def self.complete_recipient!(recipient, status, sid)
      transition = Service::TwilioResponseMapper.recipient_callback(status)
      recipient.send(transition, sid, nil, nil)
    end

    def complete_recipient_with_error!(options, error_message)
      _, recipient = find_message_and_recipient(options)
      recipient.failed!(nil, nil, error_message)
    end
  end
end
