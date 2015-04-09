module Sidekiq
  class RateLimitedQueue
    class LockInvalidator
      include Sidekiq::Worker
      sidekiq_options retry: false, unique: true

      def perform
        reset_queues = Sidekiq::RateLimitedQueue.throttled_queues.select do |queue_name|
          Sidekiq::RateLimitedQueue.new(queue_name, Sidekiq.redis_pool).check_rate_limit!
        end
        logger.info("Reset queues #{reset_queues.join(', ')}") if reset_queues.any?
      end
    end
  end
end
