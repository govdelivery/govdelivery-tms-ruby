module Analytics
  class BounceListener < JaketyJak::Subscriber::Managed
    def topic
      'tms_bounce_channel'
    end

    def group
      'xact.bounce_listener'
    end

    def on_message(message, _partition, _offset)
      logger.info("#{self.class} received #{message}")
      Analytics::ProcessBounce.perform_async(message.to_hash)
    end

    def logger
      Sidekiq.logger
    end
  end
end
