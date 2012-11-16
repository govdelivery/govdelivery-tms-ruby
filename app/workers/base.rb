module Workers
  module Base
    def self.included(base)
      base.send(:include, Sidekiq::Worker)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      # Sidekiq wants to use its own logger which goes to STDOUT.
      # Log4r claims to be thread-safe, so use it in favor of Sidekiq's logger. 
      def logger
        Rails.logger
      end
    end
  end
end