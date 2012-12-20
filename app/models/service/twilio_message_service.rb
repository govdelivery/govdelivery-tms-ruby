class TwilioMessageService
  attr_accessor :username, :password

  def initialize(username, password)
    self.username = username
    self.password = password
  end

  # message: an AR Message object
  def send(message, callback_url = nil)
    # set up a client to talk to the Twilio REST API
    client = Twilio::REST::Client.new(self.username, self.password)

    account = client.account

    message.process_blacklist!
    message.recipients.to_send.find_each do |recipient|
      logger.debug("Sending SMS to #{recipient.phone}")
      begin
        create_options = {
            :from => message.vendor.from,
            :to => "#{recipient.formatted_phone}",
            :body => message.short_body
          }
        create_options[:StatusCallback] = callback_url if callback_url
        twilio_response = account.sms.messages.create(create_options)
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
    message.save!
  end

  def logger
    @logger ||= Rails.logger
  end
end