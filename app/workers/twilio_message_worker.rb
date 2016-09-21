#
# This is a vendor worker that creates a batch of Twilio::SenderWorker jobs (one per recipient)
# via Service::TwilioMessageService
#
require 'base'
class TwilioMessageWorker < BaseMessageWorker
  sidekiq_options retry: 0, queue: :sender

  def perform(opts)
    super { Service::TwilioMessageService.deliver!(message, callback_url) }
  end

  def get_message(message_id)
    SmsMessage.find_by_id(message_id)
  end
end
