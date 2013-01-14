module Service
  module TwilioServiceHelper

    def complete!(recipient, response=nil, error=nil)
      unless response.nil?
        status = case response.status
          when 'queued', 'sending', 'ringing', 'in-progress', 'busy', 'no-answer'
            RecipientStatus::STATUS_SENDING
          when 'sent', 'completed'
            RecipientStatus::STATUS_SENT
          when 'failed'
            RecipientStatus::STATUS_FAILED
          when 'canceled'
            RecipientStatus::STATUS_CANCELED
          else
            RecipientStatus::STATUS_NEW
        end
      end
      recipient.complete!(:ack=> (response.sid rescue nil), :error_message=>error, :status=>status)
    end

    def create_options(message, recipient, callback_url, message_url=nil)
      opts = {
        :to => "#{recipient.formatted_phone}",
        :from => message.vendor.from,
      }
      opts[:body] = message.body if message.respond_to?(:body)
      opts.tap do |h|
        h[:StatusCallback] = callback_url if callback_url
        h[:url]            = message_url  if message_url
      end
    end

    def twilio_client
      @twilio_client ||= Twilio::REST::Client.new(username, password).account
    end

    def logger
      @logger ||= Rails.logger
    end
  end
end