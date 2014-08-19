require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0

  def perform(options)
    if @message
      @message.sending!
      @message.sendable_recipients.except(:order).find_each do |recipient|
        recipient.sending!(ack)
        recipient.sent!(ack)
      end
      logger.warn("#{self.class.name} #{@message.to_s} could not be completed: #{@message.recipient_counts}") unless @message.complete!
    else
      logger.warn("Unable to find message: #{options}")
    end
  end

  def ack
    @ack ||= "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
  end
end
