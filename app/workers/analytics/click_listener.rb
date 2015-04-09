module Analytics
  class ClickListener < JaketyJak::Subscriber::Managed
    def topic
      'click_channel'
    end

    def group
      'xact.click_listener'
    end

    def on_message(message, _partition, _offset)
      logger.info("#{self.class} received #{message}")
      logger.info("#{client.partition_status}")
    end

    def logger
      Sidekiq.logger
    end
  end
end
