module Mblox
  class SenderWorker
    include Workers::Base

    delegate :url_helpers, to: "Rails.application.routes"

    sidekiq_options retry: 0, queue: :sender
    RETRY_CODES = [401, 404, 429, 500]

    sidekiq_retries_exhausted do |msg|
      Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      complete_recipient_with_error!(msg['args'].first.symbolize_keys, msg['error_message'])
    end

    class << self
      def complete_recipient_with_error!(options, error_message)
        recipient = SmsRecipient.where(message_id: options[:message_id], id: options[:recipient_id]).first || raise(ActiveRecord::RecordNotFound)
        recipient.failed!(nil, nil, error_message)
      end

      def sending!(recipient, ack)
        recipient.sending!(ack)
      end
    end

    def perform(options={})
      @options = options.symbolize_keys!

      if (batch = send_batch!)
        begin
          self.class.sending!(recipient, batch.id)
        rescue ActiveRecord::ConnectionTimeoutError => e
          self.class.delay(retry: 10).sending!(recipient, batch.id)
          raise e
        end
      end
    end

    private

    def send_batch!
      begin
        logger.debug {"Sending message to #{recipient.phone}"}
        batch = Brick::Batch.create({from: vendor.from, to: [recipient.phone], callback_url: url_helpers.mblox_url, delivery_report: "per_recipient", body: message.body})
        logger.info {"Response from MBlox: #{batch.inspect}"}
      rescue Brick::Errors::ClientError => e
        raise Sidekiq::Retries::Retry.new(e) if RETRY_CODES.include?(e.response[:status])
        logger.warn {"Non-retryable error from MBlox (#{e.class.name}): #{e.response[:status]} - #{e.try(:message) || 'no message'}"}
        recipient.failed!(nil, nil, e.message)
      rescue StandardError => e
        raise Sidekiq::Retries::Retry.new(e)
      end
      batch
    end

    def recipient
      @recipient ||= get_recipient_vendor_message[0]
    end

    def vendor
      @vendor ||= get_recipient_vendor_message[1]
    end

    def message
      @message ||= get_recipient_vendor_message[2]
    end

    def get_recipient_vendor_message
      @recipient_vendor_message ||= begin
        temp_message = nil
        temp_recipient = nil
        temp_vendor = nil
        ActiveRecord::Base.connection_pool.with_connection do
          temp_message = SmsMessage.includes(:sms_vendor).find(@options[:message_id])
          temp_recipient = temp_message.recipients.find(@options[:recipient_id])
          temp_vendor = temp_message.vendor
        end
        [temp_recipient, temp_vendor, temp_message]
      end
    end
  end
end
