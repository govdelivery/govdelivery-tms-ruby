require 'base'
class TwilioMessageWorker
  include Workers::Base
  sidekiq_options retry: false

  def self.vendor_type
    :sms
  end

  def perform(options)
    options.symbolize_keys!

    message_id = options[:message_id]
    callback_url = options[:callback_url]

    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")

    if message = Message.find_by_id(message_id)
      Service::TwilioSmsMessageService.new(message.vendor.username, message.vendor.password).deliver!(message, callback_url)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
