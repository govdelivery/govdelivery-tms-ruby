require 'base'
module Analytics
  class PublisherWorker
    include Workers::Base
    sidekiq_options retry: 0
    sidekiq_retry_in { 15 }

    def perform(opts)
      return unless Conf.analytics_enabled
      validate_opts(opts.symbolize_keys!)
      channel = opts[:channel]
      message = opts[:message].merge('src' => 'xact')
      logger.info("#{self.class}: Publishing #{channel} #{message}")
      ## JaketyJak compatibility mode enabled!
      # http://dev-scm.office.gdi/analytics/jakety_jak/blob/master/lib/jakety_jak/publisher.rb#L15
      stringified_message = {}
      message.each do |key, value|
        stringified_message[key.to_s] = value.to_s
      end
      publisher.publishJSON(channel, stringified_message)
    rescue Timeout::Error => e
      raise Sidekiq::Retries::Retry.new(e)
    end

    def self.perform_inline_or_async(opts)
      new.perform(opts)
    rescue StandardError => e
      Sidekiq.logger.warn("#{self}: Error while publishing Kafka event inline: #{e.inspect}. Retrying asynchronously...")
      perform_async(opts)
    end

    private

    def publisher
      Synapse
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
