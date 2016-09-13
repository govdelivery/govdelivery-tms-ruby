class BaseMessageWorker
  include Workers::Base
  attr_reader :options

  def perform(opts)
    self.options=opts
    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")
    raise Sidekiq::Retries::Retry.new(RuntimeError.new("#{message.class.name} #{message.id} is not ready for delivery!")) unless message.may_sending?
    yield(message, callback_url)
  end

  def options=(options)
    @options ||= options.symbolize_keys!
  end

  def message_id
    options[:message_id]
  end

  def callback_url
    options[:callback_url]
  end

  def message
    @message ||= retryable_connection { SmsMessage.find(message_id) }
  end

  def sendable_recipient_ids
    rel = message.sendable_recipients
    rel.select("#{rel.table_name}.id")
  end

  def recipient_batch(message)
    message.sending!
    batch             = Sidekiq::Batch.new
    batch.description = "Send #{message.class.name} #{message.id}"
    batch.jobs do
      sendable_recipient_ids.find_each do |recipient|
        yield(message, recipient)
      end
    end
  end
end