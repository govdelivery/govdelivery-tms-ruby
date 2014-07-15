module Analytics
  class ClickListener < ListenerBase
    def channel
      'click_channel'
    end

    def group_id
      'xact.click_listener'
    end
    
    def on_message(message, partition, offset)
      Rails.logger.info("#{self.class} received #{message}")
    end
  end
end
    