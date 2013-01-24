require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: false

  def perform(options)
    if @message
      @message.process_blacklist!
      @message.sendable_recipients.find_each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        recipient.complete!(:ack => ack,
                            :status => RecipientStatus::SENT
        )
      end
      @message.complete!
    else
      logger.warn("Unable to find message: #{options}")
    end
  end

  def ack
    "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
  end
end
