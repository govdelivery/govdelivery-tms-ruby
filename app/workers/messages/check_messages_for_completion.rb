require 'base'

module Messages
  class CheckMessagesForCompletion
    include Workers::Base
    sidekiq_options queue: :low, retry: false, unique: true

    def perform(*_args)
      batch             = Sidekiq::Batch.new
      batch.description = self.class.name
      batch.expires_in 8.hours
      batch.jobs do
        [SmsMessage, VoiceMessage, EmailMessage].each do |message_class|
          message_scope(message_class).find_each do |message|
            Messages::CheckMessageForCompletion.perform_async(message_class: message_class.name, message_id: message.id)
          end
        end
      end
    end

    def message_scope(message_class)
      message_class.sending.select(:id).order('sent_at ASC')
    end
  end
end
