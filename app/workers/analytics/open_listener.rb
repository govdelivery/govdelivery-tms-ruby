module Analytics
  class OpenListener < ListenerBase
    def channel
      'open_channel'
    end

    def on_message(message, partition, offset)
      Rails.logger.info("#{self.class} received #{message}")
    end
  end
end