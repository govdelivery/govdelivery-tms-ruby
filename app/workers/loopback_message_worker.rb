require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0

  def perform(options)
    if @message
      @message.sending!
      @message.sendable_recipients.except(:order).find_each do |recipient|
        if magic_sending?(recipient)
          logger.info("Magic Sending Number: Going to Sending State.")
          recipient.sending!(ack)
        elsif magic_inconclusive?(recipient)
          logger.info("Magic Inconclusive Number: Going to Inconclusive State.")
          recipient.mark_inconclusive!
        elsif magic_canceled?(recipient)
          logger.info("Magic Canceled Number: Going to Canceled State.")
          recipient.canceled!(ack)
        elsif magic_sent?(recipient)
          logger.info("Magic Sent Number: Going to Sent State.")
          recipient.sent!(ack)
        elsif magic_failed?(recipient)
          logger.info("Magic Failed Number: Going to Failed State.")
          recipient.failed!(ack)
        elsif magic_blacklisted?(recipient)
          logger.info("Magic Blacklisted Number: Going to Blacklisted State.")
          recipient.blacklist!
        end
      end
      logger.warn("#{self.class.name} #{@message.to_s} could not be completed: #{@message.recipient_counts}") unless @message.complete!
    else
      logger.warn("Unable to find message: #{options}")
    end
  end

  def ack
    @ack ||= "#{(Time.now.to_i + Random.rand(100000)).to_s(16)}"
  end

  def magic_sending?(recipient)
    recipient.respond_to?(:phone) && recipient.phone == '15005550000'
  end

  def magic_inconclusive?(recipient)
    recipient.respond_to?(:phone) && recipient.phone == '15005550001'
  end

  def magic_canceled?(recipient)
    recipient.respond_to?(:phone) && recipient.phone == '15005550002'
  end

  def magic_sent?(recipient)
    recipient.respond_to?(:phone) && recipient.phone == '15005550003'
  end

  def magic_failed?(recipient)
    recipient.respond_to?(:phone) && recipient.phone == '15005550004'
  end

  def magic_blacklisted?(recipient)
    recipient.respond_to?(:phone) && recipient.phone == '15005550005'
  end
end
