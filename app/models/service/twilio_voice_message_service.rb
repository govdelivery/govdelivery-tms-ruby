module Service
  class TwilioVoiceMessageService
    include Service::TwilioServiceHelper

    attr_accessor :username, :password 

    def initialize(username, password)
      self.username = username
      self.password = password
    end

    def deliver!(message, message_url, callback_url)
      message.sendable_recipients.find_each do |recipient|
        logger.debug("Sending voice msg to #{recipient.phone}")
        begin
          call_opts = create_options(message, recipient, callback_url, message_url)
          resp = twilio_client.calls.create(call_opts)
          logger.info("Response from Twilio was #{resp.inspect}")
          complete!(recipient, resp)
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