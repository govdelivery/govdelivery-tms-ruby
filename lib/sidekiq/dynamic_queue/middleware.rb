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
          worker = worker.constantize if worker.is_a?(String)
          return queue unless queue_proc = worker.get_sidekiq_options['dynamic_queue_key']
          possible_queue = [msg['queue'], queue_proc.call(*msg['args'])].compact.join('_')
          Sidekiq::RateLimitedQueue.includes_queue?(possible_queue) ? possible_queue : queue
        end

      end
    end
  end
end