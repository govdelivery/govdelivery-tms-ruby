require 'base'
class TwilioVoiceWorker
  include Workers::Base
  sidekiq_options retry: false

  def perform(options)
    options.symbolize_keys!
    callback_url = options[:callback_url]

    if message = VoiceMessage.find(options[:message_id])
      logger.info("Send initiated for message_id=#{message.id} and callback_url=#{callback_url}")
      client = Service::TwilioClient::Voice.new(message.vendor.username, message.vendor.password)
      Service::TwilioMessageService.new(client).deliver!(message, callback_url, options[:message_url])
    end
  end
end
