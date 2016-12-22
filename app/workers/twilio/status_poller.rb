module Twilio
  module StatusPoller
    extend ActiveSupport::Concern

    included do
      include Workers::Base
      sidekiq_options retry:               false,
                      queue:               :stats,
                      unique:              :while_executing,
                      run_lock_expiration: 2 * 60 * 60 # 1 hours
      cattr_accessor :service, :recipient_class
    end

    def perform(*_args)
      recipient_class.to_poll.find_each do |recipient|
        recipient.failed! && next if recipient.ack.nil?
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
      @clients[username] ||= service.new(username, password).delivery
    end
  end
end
