module Sidekiq
  module DynamicQueue
    module Middleware
      class Client

        def call(worker, item, queue, redis_pool=nil)
          yield
          item['queue'] = queue_for(worker, item, queue)
          if item['queue'] != queue
            queue.gsub!(queue.dup, item['queue'])
          end
          item
        end

        def queue_for(worker, msg, queue)
          return queue unless queue_proc = worker.get_sidekiq_options['dynamic_queue_key']
          queue_suffix = queue_proc.call(*msg['args'])
          queue_suffix = nil unless Sidekiq::RateLimitedQueue.includes_queue?(queue_suffix)
          [msg['queue'], queue_suffix].compact.join('_')
        end

      end
    end
  end
end