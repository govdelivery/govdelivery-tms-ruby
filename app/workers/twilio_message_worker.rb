#
# This is a vendor worker that creates a batch of Twilio::SenderWorker jobs (one per recipient)
# via Service::TwilioMessageService
#
require 'base'
class TwilioMessageWorker
  include Workers::Base
  sidekiq_options retry: false, queue: :sender

  def perform(options)
    options.symbolize_keys!
    message_id = options[:message_id]
    callback_url = options[:callback_url]

    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")
    if message = SmsMessage.select('id, sms_vendor_id, account_id, status').find_by_id(message_id)
      Service::TwilioMessageService.deliver!(message, callback_url)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
