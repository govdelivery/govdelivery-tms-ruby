module Analytics
  class ClickListener < JaketyJak::Subscriber::Managed
    def topic
      'click_channel'
    end

    def group
      'xact.click_listener'
    end
    
    def on_message(message, partition, offset)
      Rails.logger.info("#{self.class} received #{message}")
      Rails.logger.info("#{self.client.partition_status}")
    end
  end
end
