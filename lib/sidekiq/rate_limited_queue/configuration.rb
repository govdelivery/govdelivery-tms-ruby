module Sidekiq
  class RateLimitedQueue
    class Configuration
      module ClassMethods
        def load!(filename)
          @config_filename = filename
          reload!.tap do
            merge_rate_limited_queues!
          end
        end

        def merge_rate_limited_queues!(queues = Sidekiq.options[:queues], rlqs = Sidekiq::RateLimitedQueue.throttled_queues)
          rlqs.reject { |rlq| queues.include?(rlq) }.each do |rlq|
            index = queues.index { |q| rlq =~ /^#{q}/ } || queues.length
            queues.insert(index + 1, rlq)
          end
        end

        def reload!
          config = YAML.load(File.read(@config_filename)) || {}
          Sidekiq.redis_pool.with do |conn|
            conn.multi do
              conn.del(QUEUE_LIST_KEY)
              config.keys.each { |queue_name| conn.sadd(QUEUE_LIST_KEY, queue_name) }
            end
          end
          Sidekiq.logger.info("Reloaded queue rate limits: #{config}")
          ::Sidekiq::RateLimitedQueue.config = config
        end
      end

      extend ClassMethods
    end
  end
end
