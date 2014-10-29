module Sidekiq
  class RateLimitedQueue
    attr_reader :name, :interval, :max_jobs, :redis_pool, :key
    cattr_accessor :config
    delegate :pause!, :unpause!, :paused?, to: :queue

    PREFIX         = 'throttled_queue'
    QUEUE_LIST_KEY = [PREFIX, "queues"].join(':')

    def self.throttled_queues
      Sidekiq.redis_pool.with { |conn| conn.smembers(QUEUE_LIST_KEY) }
    end

    def self.includes?
      Sidekiq.redis_pool.with { |conn| conn.sismember(QUEUE_LIST_KEY, name) }
    end

    def initialize(name, redis_pool)
      @name       = name
      @redis_pool = redis_pool
      if self.class.config && (queue_config = self.class.config[name])
        @interval = queue_config['interval']
        @max_jobs = queue_config['limit']
      end
      @key = "#{PREFIX}:#{self.name}"
    end

    def enforce_rate_limit!
      return false unless self.interval
      job_count = current.to_i
      if rate_limited = (job_count == max_jobs)
        logger.info("Queue #{self.name} had #{job_count.to_i} jobs performed within #{self.interval}-second interval, pausing.")
        self.pause!
      else
        redis_pool.with do |conn|
          if conn.incr(key)==1
            conn.expire(key, interval)
          end
        end
      end
      rate_limited
    end

    def check_rate_limit!
      if paused? && was_rate_limited = (current.nil? && rate_limiting_enabled?)
        logger.info("Queue #{self.name} was rate limited and key expired, unpausing.")
        self.unpause!
      end
      !!was_rate_limited
    end

    def rate_limiting_enabled?
      self.class.include?(name)
    end

    private

    def logger
      Sidekiq.logger
    end

    def current
      redis_pool.with { |conn| conn.get(self.key) }
    end

    def queue
      @queue ||= Sidekiq::Queue.new(self.name)
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add self.class::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add self.class::Middleware::Client
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add self.class::Middleware::Client
  end
end

