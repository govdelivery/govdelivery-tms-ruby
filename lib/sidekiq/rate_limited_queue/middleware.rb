module Sidekiq
  class ThrottledQueue
    module Middleware
      class Server

        def call(worker, item, queue, redis_pool=Sidekiq.redis_pool)
          Sidekiq::ThrottledQueue.new(queue, redis_pool).enforce_rate_limit!
          yield
        end

      end

      class Client

        def call(worker, item, queue, redis_pool=Sidekiq.redis_pool)
          Sidekiq::ThrottledQueue.new(queue, redis_pool).check_rate_limit!
          yield
        end
      end
    end
  end
end