module GovDelivery
  module HealthCheck
    module Checks
      class RailsCache < Base
        CACHE_KEY = 'health_check:sysdate'

        # warn if we can't access the cache, but don't consider it fatal
        def check!
          pass! unless defined?(::Rails) && ::Rails.respond_to?(:cache)

          warn!("#{self.class.name}: cache write failed") unless ::Rails.cache.write(CACHE_KEY, Time.now.to_s)
          warn!("#{self.class.name}: cache read failed") unless ::Rails.cache.read(CACHE_KEY)
        end
      end
    end
  end
end
