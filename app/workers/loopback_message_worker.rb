require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: false

  def perform(options)
    if @message
      @message.sending!('looped_back')
      @message.sendable_recipients.sending.except(:order).update_all(:status => RecipientStatus::SENT, :completed_at => DateTime.now)
      @message.check_complete!
    else
      logger.warn("Unable to find message: #{options}")
    end
  end

  def ack
    "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
  end
end
