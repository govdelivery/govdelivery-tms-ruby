require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: false

  def perform(options)
    message_id = options['message_id']
    if message = SmsMessage.find_by_id(message_id)
      logger.info("Send initiated for SmsMessage #{message_id}")
    elsif message = VoiceMessage.find_by_id(message_id)
      logger.info("Send initiated for VoiceMessage #{message_id}")
    end

    if message
      message.process_blacklist!
      message.recipients.to_send.find_each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        recipient.complete!(:ack => ack,
                            :status => RecipientStatus::STATUS_SENT
        )
      end
      message.complete!
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end

  def ack
    "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
  end
end
