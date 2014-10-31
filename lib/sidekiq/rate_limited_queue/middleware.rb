module Sidekiq
  class RateLimitedQueue
    module Middleware
      class Server

        def call(worker, item, queue, redis_pool=Sidekiq.redis_pool)
          yield.tap do
            begin
              Sidekiq::RateLimitedQueue.new(queue, redis_pool).enforce_rate_limit!
            rescue Redis::BaseError => ex
              ::Sidekiq.logger.warn(ex.message)
              # don't blow up if redis is having a problem
            end
          end
        end

      end

      class Client

        def call(worker, item, queue, redis_pool=Sidekiq.redis_pool)
          yield.tap do
            begin
              Sidekiq::RateLimitedQueue.new(queue, redis_pool).check_rate_limit!
            rescue Redis::BaseError => ex
              ::Sidekiq.logger.warn(ex.message)
              # don't blow up if redis isn't available
            end
            true
          end
        end
      end
    end
  end
end