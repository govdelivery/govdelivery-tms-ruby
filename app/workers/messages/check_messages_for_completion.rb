require 'base'

module Messages
  class CheckMessagesForCompletion
    include Workers::Base
    sidekiq_options queue: :low, retry: false
    JOB_KEY = "xact:#{self.name}_bid"

    class OnComplete
      def on_complete(status, options)
        Rails.cache.delete(JOB_KEY)
      end
    end

    def perform(*args)
      return if batch_in_progress?
      batch             = Sidekiq::Batch.new
      batch.description = self.class.name
      batch.expires_in 8.hours
      batch.on(:success, OnComplete, 'job_key' => JOB_KEY)
      batch.jobs do
        [SmsMessage, VoiceMessage, EmailMessage].each do |message_class|
          message_scope(message_class).find_each do |message|
            Messages::CheckMessageForCompletion.perform_async(message_class: message_class.name, message_id: message.id)
          end
        end
      end
    end

    def batch_in_progress?
      Rails.cache.read(JOB_KEY)
    end

    def message_scope(message_class)
      message_class.sending.select(:id).order('sent_at ASC')
    end
  end
end
