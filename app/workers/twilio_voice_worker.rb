require 'base'
class TwilioVoiceWorker
  include Workers::Base
  sidekiq_options retry: false
  
  def perform(options)
    options.symbolize_keys!    

    message_id   = options[:message_id]
    callback_url = options[:callback_url]
    message_url  = options[:message_url]
    
    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")
    logger.debug("******************************* #{Message.find_by_id(message_id).to_yaml}")

    if message = Message.find_by_id(message_id)
      Service::TwilioVoiceMessageService.new(message.vendor.username, message.vendor.password).deliver!(message, message_url, callback_url)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
