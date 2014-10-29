module Sidekiq
  module DynamicQueue
    module Middleware
      class Client

        def call(worker, item, queue, redis_pool=nil)
          item['queue'] = queue_for(worker, item, queue)
          unless item['queue'] == queue
            queue.gsub!(queue.dup, item['queue'])
          end
        end

        def queue_for(worker, msg, queue)
          return queue unless queue_proc = worker.get_sidekiq_options['dynamic_queue_key']
          [msg['queue'], queue_proc.call(msg['args']) || nil].compact.join('_')
        end

      end
    end
  end
end