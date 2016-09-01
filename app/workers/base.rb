module Workers
  module Base
    def self.included(base)
      base.send(:include, Sidekiq::Worker)
    end

    def retryable_connection(&block)
      begin
        block.call
      rescue ActiveRecord::ConnectionTimeoutError => e
        logger.info("Connection Timeout Error for #{self.class.name}, retrying")
        raise Sidekiq::Retries::Retry.new(e)
      end
    end
  end
end
