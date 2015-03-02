module Analytics
  class BounceListener < JaketyJak::Subscriber::Managed
    def topic
      'tms_bounce_channel'
    end

    def group
      'xact.bounce_listener'
    end

    def on_message(message, partition, offset)
      Rails.logger.info("#{self.class} received #{message}")
      EmailRecipient.from_x_tms_recipent(message['recipient']).send("#{message['uri']}!", nil, nil, message['message'])
    end
  end
end