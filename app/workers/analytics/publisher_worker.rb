require 'base'
module Analytics
  class PublisherWorker
    include Workers::Base
    sidekiq_options retry: false

    CONNECTION_POOL = ConnectionPool.new(size: 5, timeout: 5) do
      YaketyYak::Publisher.new('xact')
    end

    def perform(opts)
      if Rails.configuration.analytics[:enabled]
        opts.symbolize_keys!
        validate_opts(opts)    
        channel = opts[:channel]
        message = opts[:message].merge(:src => 'xact')
        CONNECTION_POOL.with do |connection|
          Rails.logger.info("#{self.class}: Publishing #{channel} #{message}")
          connection.publish(channel, message)
        end
      end
    end

  private
    def validate_opts(opts)
      unless opts[:channel] && opts[:message]
        raise ArgumentError.new("Expected #{opts} to have :channel and :message")
      end
      unless opts[:message].respond_to?(:merge)
        raise ArgumentError.new("Expected :message to be a Hash, got: #{opts}")
      end
    end
  end
end