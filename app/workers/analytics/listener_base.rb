module Analytics
  class ListenerBase
    include Celluloid
    attr_accessor :client

    def initialize
      Rails.logger.info "#{self.class} starting #{Thread.current.object_id} in #{Rails.env}"
    end

    def listen
      begin
        client.each_message do |message, partition, offset|
          on_message(message, partition, offset)
        end
      rescue Exception => e
        Rails.logger.error "#{self.class} #{e.class} #{e}"
      end
    end

    def client
      # Subscribe to the channel, look for messages with 'src' => 'xact'
      @client ||= YaketyYak::Subscriber.new(self.channel, 'xact')
    end

    def channel
      raise NotImplementedError.new("You must implement #channel")
    end

    def on_message(message, partition, offset)
      raise NotImplementedError.new("You must implement #on_message")
    end
  end
end