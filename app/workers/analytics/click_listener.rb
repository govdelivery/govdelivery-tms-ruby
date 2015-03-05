module Analytics
  class ClickListener < JaketyJak::Subscriber::Managed
    def topic
      'click_channel'
    end

    def group
      'xact.click_listener'
    end

    def on_message(message, partition, offset)
      logger.info("#{self.class} received #{message}")
      logger.info("#{self.client.partition_status}")
    end

    def logger
      Sidekiq.logger
    end
  end
end
