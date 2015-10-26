module Sidekiq
  module RetryAwareWorker
    class Middleware
      def call(worker, job, queue, redis_pool=Sidekiq.redis_pool)
        if(job["retry_count"])
          worker.retry_count = job["retry_count"]
        end
        yield
      end
    end
  end
end
