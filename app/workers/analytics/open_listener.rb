require 'jakety_jak'
module Analytics
  class OpenListener < JaketyJak::Subscriber::Managed
    def topic
      'open_channel'
    end

    def group
      'xact.open_listener'
    end

    def on_message(message, _partition, _offset)
      Sidekiq.logger.info("#{self.class} received #{message}")
    end
  end
end
