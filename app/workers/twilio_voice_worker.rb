#
# This is a vendor worker that creates a batch of Twilio::SenderWorker jobs (one per recipient)
# via Service::TwilioMessageService
#
require 'base'
class TwilioVoiceWorker
  include Workers::Base
  sidekiq_options retry: false, queue: :sender

  def perform(options)
    options.symbolize_keys!
    message_id = options[:message_id]
    callback_url = options[:callback_url]
    message_url = options[:message_url]

    if message = VoiceMessage.select('id, account_id, play_url').find(message_id)
      logger.info("Send initiated for message_id=#{message.id} and callback_url=#{callback_url}")
      Service::TwilioMessageService.deliver!(message, callback_url, message_url)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
