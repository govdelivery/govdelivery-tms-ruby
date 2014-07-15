module Analytics
  class OpenListener < ListenerBase
    def channel
      'open_channel'
    end

    def group_id
      'xact.open_listener'
    end
    
    def on_message(message, partition, offset)
      Rails.logger.info("#{self.class} received #{message}")
    end
  end
end