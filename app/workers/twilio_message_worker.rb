#
# This is a vendor worker that creates a batch of Twilio::SenderWorker jobs (one per recipient)
# via Service::TwilioMessageService
#
require 'base'
class TwilioMessageWorker
  include Workers::Base
  sidekiq_options retry: 0, queue: :sender

  def perform(options)
    options.symbolize_keys!
    message_id = options[:message_id]
    callback_url = options[:callback_url]

    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")
    if message = retryable_connection { get_message(message_id) }
      raise Sidekiq::Retries::Retry.new(RuntimeError.new("#{message.class.name} #{message.id} is not ready for delivery!")) unless message.may_sending?
      Service::TwilioMessageService.deliver!(message, callback_url)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end

  def get_message(message_id)
    SmsMessage.find_by_id(message_id)
  end
end
