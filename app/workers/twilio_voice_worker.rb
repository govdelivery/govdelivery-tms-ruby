require 'base'
class TwilioVoiceWorker
  include Workers::Base
  sidekiq_options retry: false

  def perform(options)
    options.symbolize_keys!
    callback_url = options[:callback_url]

    if message = VoiceMessage.find(options[:message_id])
      logger.info("Send initiated for message_id=#{message.id} and callback_url=#{callback_url}")
      Service::TwilioVoiceMessageService.new(message.vendor.username, message.vendor.password).deliver!(message, options[:message_url], callback_url)
    end
  end
end
