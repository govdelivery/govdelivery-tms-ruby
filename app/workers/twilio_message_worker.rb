class TwilioMessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(message_id)
    logger.info("Send initiated for message=#{message_id}")

    if message = Message.find_by_id(message_id)

      # set up a client to talk to the Twilio REST API
      client = Twilio::REST::Client.new(message.vendor.username, message.vendor.password)

      account = client.account

      message.process_blacklist!
      message.recipients.incomplete.not_blacklisted.find_each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        begin
          twilio_response = account.sms.messages.create({
              :from => message.vendor.from,
              :to => "#{recipient.formatted_phone}",
              :body => message.short_body
            })
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
          logger.warn("Failed to send SMS to #{recipient.phone} for message #{message.id}: #{e.inspect}")
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