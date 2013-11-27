module Twilio
  module StatusPoller
    extend ActiveSupport::Concern

    included do
      include Workers::Base
      sidekiq_options unique: true, retry: false
      cattr_accessor :service, :recipient_class
    end

    def perform(*args)
      self.recipient_class.to_poll.find_each do |recipient|
        begin
          client = get_client(recipient.vendor.username, recipient.vendor.password)
          twilio_message = client.get(recipient.ack)
          recipient.send(callback(twilio_message.status), twilio_message.sid, twilio_message.date_sent)
        rescue Twilio::REST::RequestError => e
          logger.warn("Couldn't look up #{recipient.class.name} #{recipient.ack}: #{e.message}\n #{e.backtrace.join("\n")}")
        end
      end
    end

    def callback(status)
      Service::TwilioResponseMapper.recipient_callback(status)
    end

    def get_client(username, password)
      @clients ||= {}
      @clients[username] ||= self.service.new(username, password).delivery
    end
  end
end