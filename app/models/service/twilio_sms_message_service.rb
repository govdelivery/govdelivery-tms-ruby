module Service
  class TwilioSmsMessageService
    include Service::TwilioServiceHelper

    attr_accessor :username, :password

    def initialize(username, password)
      self.username = username
      self.password = password
    end

    def deliver!(message, callback_url = nil)
      message.process_blacklist!
      message.recipients.to_send.find_each do |recipient|
        logger.debug("Sending SMS to #{recipient.phone}")
        begin
          response = twilio_client.sms.messages.create(create_options(message, recipient, callback_url))
          logger.info("Response from Twilio was #{response.inspect}")
          complete!(recipient, response)
        rescue Twilio::REST::RequestError => e
          logger.warn("Failed to send #{message} to #{recipient.phone}: #{e.inspect}")
          complete!(recipient, nil, e.to_s)
        end
      end
      message.completed_at = Time.now
      message.save!
    end
  end
end