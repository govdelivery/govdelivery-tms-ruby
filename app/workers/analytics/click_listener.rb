module Analytics
  class ClickListener < YaketyYak::Subscriber::Managed
    def channel
      'click_channel'
    end

    def group_id
      'xact.click_listener'
    end
    
    def on_message(message, partition, offset)
      Rails.logger.info("#{self.class} received #{message}")
      Rails.logger.info("#{self.client.partition_status}")
    end
  end
end
    