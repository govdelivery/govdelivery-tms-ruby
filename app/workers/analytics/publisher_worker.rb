require 'base'
module Analytics
  class PublisherWorker
    include Workers::Base
    sidekiq_options retry: 0
    sidekiq_retry_in { 15 }

    # Inject the publisher
    # Disable async
    class << self
      attr_accessor :publisher, :async_disabled

      def publisher
        @publisher ||= Synapse
      end
    end

    def perform(opts)
      return unless Conf.analytics_enabled
      validate_opts(opts.symbolize_keys!)
      channel = opts[:channel]
      message = opts[:message].merge('src' => 'xact')
      logger.info("#{self.class}: Publishing #{channel} #{message}")
      publisher.publishJSON(channel, message)
    rescue Timeout::Error => e
      raise Sidekiq::Retries::Retry.new(e)
    end

    def self.perform_inline_or_async(opts)
      new.perform(opts)
    rescue StandardError => e
      raise e if async_disabled
      Sidekiq.logger.warn("#{self}: Error while publishing Kafka event inline: #{e.inspect}. Retrying asynchronously...")
      perform_async(opts)
    end

    private

    def publisher
      self.class.publisher
    end

    def async_disabled
      self.class.async_disabled
    end

    def flatten(x)
      return x unless x.instance_of?(Array) || x.instance_of?(Hash)
      return x.flatten.map { |y| flatten(y) }.flatten
    end

    def validate_opts(opts)
      unless opts[:channel] && opts[:message]
        raise ArgumentError.new("Expected #{opts} to have :channel and :message")
      end
      unless opts[:message].respond_to?(:merge)
        raise ArgumentError.new("Expected :message to be a Hash, got: #{opts}")
      end
      raise ArgumentError.new("Serialize Date or Time before you publish!") if (flatten(opts[:message]).any?{ |x| x.instance_of?(Date) || x.instance_of?(Time)})
    end
  end
end
