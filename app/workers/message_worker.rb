class MessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(message_id)
    logger.info("Send initiated for message=#{message_id}")

    if message = Message.find_by_id(message_id)

      # set up a client to talk to the Twilio REST API
      client = Twilio::REST::Client.new(message.vendor.username, message.vendor.password)

      account = client.account
    
      message.recipients.incomplete.each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        begin
          twilio_response = account.sms.messages.create({:from => message.vendor.from, :to => "+#{recipient.country_code}#{recipient.phone}", :body => message.short_body})
          logger.info("Response from Twilio was #{twilio_response.inspect}")
          recipient.ack = twilio_response.sid
          recipient.status = twilio_response.status
        rescue Twilio::REST::RequestError => e
          logger.warn("Failed to send SMS to #{recipient.phone} for message #{message.id}: #{e.inspect}")
          recipient.status = 'failed'
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