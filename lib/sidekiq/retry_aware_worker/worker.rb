module Sidekiq
  module RetryAwareWorker
    module Worker
      def self.included(base)
        base.send(:attr_accessor, :retry_count)
      end

      def retrying?
        !retry_count.nil?
      end
    end
  end
end
