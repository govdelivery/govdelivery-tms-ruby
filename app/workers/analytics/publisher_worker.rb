require 'base'
module Analytics
  class PublisherWorker
    include Workers::Base
    sidekiq_options retry: 0
    sidekiq_retry_in { 15 }

    PUBLISHER = JaketyJak::Publisher.new(
      Rails.configuration.analytics[:kafkas].join(','),
      "#{Socket.gethostname}-#{Process.pid}",
      Conf.analytics.publisher_options.to_hash) unless Rails.env.test?

    def perform(opts)
      return unless Rails.configuration.analytics[:enabled]
      validate_opts(opts.symbolize_keys!)
      channel = opts[:channel]
      message = opts[:message].merge('src' => 'xact')
      logger.info("#{self.class}: Publishing #{channel} #{message}")
      publisher.publish(channel, message)
    rescue Timeout::Error => e
      raise Sidekiq::Retries::Retry.new(e)
    end

    def self.perform_inline_or_async(opts)
      new.perform(opts)
    rescue StandardError => e
      perform_async(opts)
    end

    private

    def publisher
      PUBLISHER
    end

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
