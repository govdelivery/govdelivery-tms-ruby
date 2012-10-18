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
        twilio_response = @account.sms.messages.create({:from => '(651) 433-6311', :to => "+#{recipient.country_code}#{recipient.phone}", :body => message.short_body})
        logger.info("Response from Twilio was #{twilio_response.inspect}")
        recipient.ack = twilio_response.sid
        recipient.completed = Time.now
        recipient.save
      end

      message.update_attributes(:completed => Time.now)
    else
      logger.warn("Send failed, unable to find message with id #{message_id}")
    end
  end
end