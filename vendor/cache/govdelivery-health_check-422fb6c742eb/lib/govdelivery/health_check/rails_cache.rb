module GovDelivery
  module HealthCheck
    class RailsCache
      include Singleton
      CACHE_KEY = 'health_check:sysdate'

      def check!
        return unless defined?(::Rails) && ::Rails.respond_to?(:cache)

        raise Warning.new("#{self.class.name}: cache write failed") unless ::Rails.cache.write(CACHE_KEY, Time.now.to_s)
        raise Warning.new("#{self.class.name}: cache read failed") unless ::Rails.cache.read(CACHE_KEY)
      end
    end
  end

end