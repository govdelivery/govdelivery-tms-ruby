class LoopbackMessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(message_id)
    logger.info("Send initiated for message=#{message_id}")

    if message = Message.find_by_id(message_id)
      message.recipients.incomplete.each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        recipient.ack = "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
        recipient.status = Recipient::STATUS_SENT
        recipient.completed_at = Time.now
        recipient.sent_at = Time.now
        recipient.save!
      end
      message.completed_at = Time.now
      message.save
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end