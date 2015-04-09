require 'base'
class LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0,
                  queue: :sender

  class << self
    attr_accessor :magic_addresses
  end

  def perform(options)
    if @message
      @message.sendable_recipients.except(:order).find_each do |recipient|
        case target(recipient)
        when self.class.magic_addresses[:new]
          logger.info('Magic New Recipient: Staying in New State.')
        when self.class.magic_addresses[:sending]
          logger.info('Magic Sending Recipient: Going to Sending State.')
          recipient.sending!(ack)
        when self.class.magic_addresses[:inconclusive]
          logger.info('Magic Inconclusive Recipient: Going to Inconclusive State.')
          recipient.mark_inconclusive!
        when self.class.magic_addresses[:canceled]
          logger.info('Magic Canceled Recipient: Going to Canceled State.')
          recipient.canceled!(ack)
        when self.class.magic_addresses[:failed]
          logger.info('Magic Failed Recipient: Going to Failed State.')
          recipient.failed!(ack)
        when self.class.magic_addresses[:blacklisted]
          logger.info('Magic Blacklisted Recipient: Going to Blacklisted State.')
          recipient.blacklist!
        when self.class.magic_addresses[:sent]
          logger.info('Magic Sent Recipient: Going to Sent State.')
          recipient.sent!(ack, nil, :human)
        else
          logger.info('Non-Magic Recipient: Default Action - Going to Sent State.')
          recipient.sent!(ack, nil, :machine)
        end
      end
      logger.warn("#{self.class.name} #{@message} could not be completed: #{@message.recipient_counts}") unless @message.complete!
    else
      logger.warn("Unable to find message: #{options}")
    end
  end

  def ack
    @ack ||= "#{(Time.zone.now.to_i + Random.rand(100_000)).to_s(16)}"
  end
end
