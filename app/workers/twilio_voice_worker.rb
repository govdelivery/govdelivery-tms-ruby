require 'base'
class TwilioVoiceWorker
  include Workers::Base
  sidekiq_options retry: false
  
  def perform(options)
    options.symbolize_keys!    
    message_id = options[:message_id]
    callback_url = options[:callback_url]
    message_url = options[:message_url]
    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")
    logger.info("******************************* #{Message.find_by_id(message_id).to_yaml}")

    if message = Message.find_by_id(message_id)

      # set up a client to talk to the Twilio REST API
      twilio_client = Twilio::REST::Client.new(message.vendor.username, message.vendor.password)

      twilio_account = twilio_client.account

      MessageSender.new(message.vendor.from).send!(message.recipients, ->(from, to){
        begin
          resp = twilio_account.calls.create({
                                                 :from => from,
                                                 :to => to,
                                                 :url => message_url,
                                                 :StatusCallback => callback_url
                                             })
          {ack: resp.sid, status: resp.status, error: nil}
        rescue Twilio::REST::RequestError => e
          {ack: nil, status: 'failed', error:e.to_s}
        end
      })

      message.completed_at = Time.now
      message.save!
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
