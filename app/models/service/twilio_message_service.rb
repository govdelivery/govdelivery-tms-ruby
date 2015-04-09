module Service
  class TwilioMessageService
    class << self
      def deliver!(message, callback_url = nil, message_url = nil, recipient_id = nil)
        if recipient_id.nil?
          message.sending!
          do_deliver(message, callback_url, message_url)
        else # retry single recipient
          do_retry(message, callback_url, message_url, recipient_id)
        end
      end

      private

      def do_deliver(message, callback_url, message_url = nil)
        batch = Sidekiq::Batch.new
        batch.description = "Send #{message.class.name} #{message.id}"
        batch.jobs do
          rel = message.sendable_recipients
          rel.select("#{rel.table_name}.id").find_each do |recipient|
            Twilio::SenderWorker.perform_async(message_class: message.class.name,
                                               callback_url: callback_url,
                                               message_url: message_url,
                                               message_id: message.id,
                                               recipient_id: recipient.id)
          end
        end
      end

      def do_retry(message,  callback_url, message_url = nil, recipient_id)
        Twilio::SenderWorker.perform_async(message_class: message.class.name,
                                           callback_url: callback_url,
                                           message_url: message_url,
                                           message_id: message.id,
                                           recipient_id: recipient_id)
      end
    end
  end
end
