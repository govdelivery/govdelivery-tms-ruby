# This worker actually delivers messages to Twilio
#     e.g. TwilioVoiceWorker creates a batch of n Twilio::SenderWorker jobs (one per recipient)
#
module Twilio
  class SenderWorker
    include Workers::Base
    #with the default exponential backoff, this will retry for about four hours
    sidekiq_options retry: 10
    RETRY_CODES = [401, 404, 429, 500]

    sidekiq_retries_exhausted do |msg|
      Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      self.new.complete_recipient_with_error!(msg['args'].first.symbolize_keys, msg['error_message'])
    end

    def find_message_and_recipient(options)
      message = options[:message_class].constantize.find(options[:message_id])
      recipient = message.recipients.find(options[:recipient_id])
      return message, recipient
    end

    def perform(options={})
      options.symbolize_keys!
      message, recipient = find_message_and_recipient(options)
      callback_url = options[:callback_url]
      message_url = options[:message_url]

      logger.debug { "Sending message to #{recipient.phone}" }

      begin
        client = message.vendor.delivery_mechanism
        response = client.deliver(message, recipient, callback_url, message_url)
      rescue Twilio::REST::RequestError => e
        raise if RETRY_CODES.include?(client.last_response_code)
        logger.warn { "Non-retryable error from Twilio (#{message}): #{e.code} - #{e.message}" }
        recipient.failed!(nil, e.message)
        return
      end

      # if completing blows up, don't retry since we'll send the message again
      begin
        logger.info { "Response from Twilio was #{response.inspect}" }
        complete_recipient!(recipient, response.status, response.sid)
      rescue => e
        raise Sidekiq::Retries::Fail.new(e)
      end
    end

    def complete_recipient!(recipient, status, sid)
      transition = Service::TwilioResponseMapper.recipient_callback(status)
      recipient.send(transition, sid)
    end

    def complete_recipient_with_error!(options, error_message)
      _, recipient = find_message_and_recipient(options)
      recipient.failed!(nil, error_message)
    end
  end
end