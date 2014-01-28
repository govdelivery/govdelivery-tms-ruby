module Service
  class TwilioMessageService
    class << self
      def deliver!(message, callback_url=nil, message_url=nil)
        message.process_blacklist!
        do_deliver(message, callback_url, message_url)
        message.sending!
      end

      private

      def do_deliver(message, callback_url, message_url=nil)
        err_count, total, success_count = 0, 0, 0
        batch = Sidekiq::Batch.new
        batch.description = "Send #{message.class.name} #{message.id}"
        batch.jobs do
          message.sendable_recipients.find_each do |recipient|
            Twilio::SenderWorker.perform_async(message_class: message.class.name,
                                               callback_url: callback_url,
                                               message_url: message_url,
                                               message_id: message.id,
                                               recipient_id: recipient.id)
          end
        end
      end
    end
  end
end
