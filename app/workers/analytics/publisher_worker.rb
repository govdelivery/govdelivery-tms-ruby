require 'base'
module Analytics
  class PublisherWorker
    include Workers::Base
    sidekiq_options retry: 0
    sidekiq_retry_in { 10 }

    CONNECTION_POOL = ConnectionPool.new(size: 5, timeout: 5) do
      YaketyYak::Publisher.new('xact')
    end

    def perform(opts)
      return unless Rails.configuration.analytics[:enabled]
      validate_opts(opts.symbolize_keys!)
      channel = opts[:channel]
      message = opts[:message].merge(src: 'xact')
      CONNECTION_POOL.with do |connection|
        logger.info("#{self.class}: Publishing #{channel} #{message}")
        connection.publish(channel, message)
      end
    rescue Timeout::Error => e
      raise Sidekiq::Retries::Retry.new(e)
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