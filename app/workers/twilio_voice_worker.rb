require 'base'
class TwilioVoiceWorker
  include Workers::Base
  sidekiq_options retry: false
  
  def perform(options)
    options.symbolize_keys!    
    message_id = options[:message_id]
    message_url = options[:message_url]
    callback_url = options[:callback_url]
    logger.info("Send initiated for message_id=#{message_id} and callback_url=#{callback_url}")
    logger.info("******************************* #{Message.find_by_id(message_id).to_yaml}")

    if message = Message.find_by_id(message_id)

      # set up a client to talk to the Twilio REST API
      client = Twilio::REST::Client.new(message.vendor.username, message.vendor.password)

      account = client.account

      message.process_blacklist!
      message.recipients.to_send.find_each do |recipient|
        logger.debug("Sending voice msg to #{recipient.phone}")
        begin
          create_options = {
              :from => message.vendor.from,
              :to => "#{recipient.formatted_phone}",
              :url => message_url
            }
          #create_options[:StatusCallback] = callback_url if callback_url
          twilio_response = account.calls.create(create_options)
          logger.info("Response from Twilio was #{twilio_response.inspect}")
          recipient.ack = twilio_response.sid
          recipient.status = case twilio_response.status
          when 'queued','sending'
            Recipient::STATUS_SENDING
          when 'sent'
            Recipient::STATUS_SENT
          else
            Recipient::STATUS_NEW
          end
        rescue Twilio::REST::RequestError => e
          logger.warn("Failed to send voice msg to #{recipient.phone} for message #{message.id}: #{e.inspect}")
          recipient.status = Recipient::STATUS_FAILED
          recipient.error_message = e.to_s
          recipient.completed_at = Time.now
        end
        recipient.sent_at = Time.now
        recipient.save!
      end

      message.completed_at = Time.now
      message.save
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end
