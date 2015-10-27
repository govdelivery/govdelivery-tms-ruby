require 'base'
class MbloxMessageWorker
  include Workers::Base
  sidekiq_options retry: 0, queue: :sender

  def perform(options)
    options.symbolize_keys!
    message_id = options[:message_id]

    logger.info("Send initiated for message_id=#{message_id}")

    if message = SmsMessage.find_by_id(message_id)
      raise Sidekiq::Retries::Retry.new(RuntimeError.new("#{message.class.name} #{message.id} is not ready for delivery!")) unless message.may_sending?

      message.sending!

      batch = Sidekiq::Batch.new
      batch.description = "Send #{message.class.name} #{message.id}"
      batch.jobs do
        rel = message.sendable_recipients
        rel.select("#{rel.table_name}.id").find_each do |recipient|
          Mblox::SenderWorker.perform_async(message_id: message.id, recipient_id: recipient.id)
        end
      end
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end