module Analytics
  class BounceListener < JaketyJak::Subscriber::Managed
    def topic
      'tms_bounce_channel'
    end

    def group
      'xact.bounce_listener'
    end

    def on_message(message, partition, offset)
      logger.info("#{self.class} received #{message}")
      recipient = EmailRecipient.from_x_tms_recipent(message['recipient'])
      recipient.send("#{message['uri']}!", nil, nil, message['message'])
    rescue ActiveRecord::RecordNotFound => e
      logger.warn("BounceListener: couldn't find EmailRecipient: #{message.inspect} - #{e.message}")
    end

    def logger
      Sidekiq.logger
    end
  end
end