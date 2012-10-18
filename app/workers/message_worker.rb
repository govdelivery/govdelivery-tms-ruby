class MessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(message_id)
    logger.info("Send initiated for message=#{message_id}")

    if message = Message.find_by_id(message_id)
      recipients = message.recipients.map{|r| "+#{r.phone}"}
    
      # set up a client to talk to the Twilio REST API
      @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

      @account = @client.account
    
      message.recipients.incomplete.each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        twilio_response = @account.sms.messages.create({:from => '468311', :to => "+1#{recipient.phone}", :body => message.short_body})
        recipient.update_attributes(:ack => twilio_response.sid, :completed => Time.now)
      end

      message.update_attributes(:completed => Time.now)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end