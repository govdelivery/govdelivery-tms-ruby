require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: false

  #These can be any type of worker, just set vendor vtype manually and this will be overridden
  def self.vendor_type
    :sms
  end

  def perform(options)
    message_id = options['message_id']
    logger.info("Send initiated for message_id=#{message_id}")

    if message = Message.find_by_id(message_id)
      message.process_blacklist!
      message.recipients.to_send.find_each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        recipient.ack = "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
        recipient.status = Recipient::STATUS_SENT
        recipient.completed_at = Time.now
        recipient.sent_at = Time.now
        recipient.save!
      end
      message.completed_at = Time.now
      message.save!
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
