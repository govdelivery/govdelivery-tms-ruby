module Sidekiq
  class ThrottledQueue
    class LockInvalidator
      include Sidekiq::Worker
      sidekiq_options retry: false, unique: true

      def perform
        Sidekiq::ThrottledQueue.throttled_queues.each do |queue_name|
          Sidekiq::ThrottledQueue.new(queue_name, Sidekiq.redis_pool).check_rate_limit!
        end
      end

    end
  end
end