module GovDelivery
  module HealthCheck
    module Checks
      class Sidekiq < Base
        CACHE_KEY = 'health_check:sidekiq:sysdate'

        # warn if no sidekiq nodes, but don't consider it fatal
        # error out if we can't talk to Redis at all (can't enqueue jobs)
        def check!
          pass! unless defined?(::Sidekiq) # don't do anything if no sidekiq

          ::Sidekiq.redis do |redis|
            # these will raise Redis::CannotConnectError if they fail
            redis.set(CACHE_KEY, Time.now.to_s)
            redis.get(CACHE_KEY)
          end

          warn!("#{self.class.name}: no active sidekiq processes") unless ::Sidekiq::ProcessSet.new.size > 0
        end
      end
    end
  end
end
