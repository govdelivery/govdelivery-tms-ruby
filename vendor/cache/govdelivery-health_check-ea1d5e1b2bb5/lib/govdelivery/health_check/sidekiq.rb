module GovDelivery
  module HealthCheck
    class Sidekiq
      include Singleton
      CACHE_KEY = 'health_check:sidekiq:sysdate'

      def check!
        return unless defined?(::Sidekiq)
        ::Sidekiq.redis do |redis|
          # these will raise Redis::CannotConnectError if they fail
          redis.set(CACHE_KEY, Time.now.to_s)
          redis.get(CACHE_KEY)
        end
        raise Warning.new("#{self.class.name}: no active sidekiq processes") unless ::Sidekiq::ProcessSet.new.size > 0
      end
    end
  end

end