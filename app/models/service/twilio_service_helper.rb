module Service
  module TwilioServiceHelper

    def complete!(recipient, response=nil, error=nil)
      unless response.nil?
        recipient.ack = response.sid
        case response.status
          when 'queued', 'sending', 'ringing', 'in-progress', 'busy', 'no-answer'
            recipient.status = Recipient::STATUS_SENDING
            recipient.sent_at = Time.now
          when 'sent', 'completed'
            recipient.status = Recipient::STATUS_SENT
          when 'failed'
            recipient.status = Recipient::STATUS_FAILED
            recipient.completed_at = Time.now
          when 'canceled'
            recipient.status = Recipient::STATUS_CANCELED
            recipient.completed_at = Time.now
          else
            recipient.status = Recipient::STATUS_NEW
        end
      end
      recipient.error_message = error
      recipient.sent_at = Time.now
      recipient.save!
    end

    def create_options(message, recipient, callback_url, message_url=nil)
      {
        :from => message.vendor.from,
        :to => "#{recipient.formatted_phone}",
        :body => message.short_body
      }.tap do |h|
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