module Sidekiq
  class RateLimitedQueue
    attr_reader :name, :interval, :max_jobs, :redis_pool, :key
    cattr_accessor :config
    delegate :pause!, :unpause!, :paused?, to: :queue

    PREFIX         = 'throttled_queue'
    QUEUE_LIST_KEY = [PREFIX, 'queues'].join(':')

    def self.throttled_queues
      Sidekiq.redis_pool.with { |conn| conn.smembers(QUEUE_LIST_KEY)}
    end

    def self.includes_queue?(name)
      Sidekiq.redis_pool.with { |conn| conn.sismember(QUEUE_LIST_KEY, name)}
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
      return false unless interval
      job_count = current.to_i
      if rate_limited = (job_count == max_jobs)
        logger.info("Queue #{name} had #{job_count.to_i} jobs performed within #{interval}-second interval, pausing.")
        self.pause!
      else
        redis_pool.with do |conn|
          conn.expire(key, interval) if conn.incr(key) == 1
        end
      end
      rate_limited
    end

    def check_rate_limit!
      if paused? && was_rate_limited = (current.nil? && rate_limiting_enabled?)
        logger.info("Queue #{name} was rate limited and key expired, unpausing.")
        self.unpause!
      end
      !!was_rate_limited
    end

    def rate_limiting_enabled?
      self.class.includes_queue?(name)
    end

    private

    def logger
      Sidekiq.logger
    end

    def current
      redis_pool.with { |conn| conn.get(key)}
    end

    def queue
      @queue ||= Sidekiq::Queue.new(name)
    end
  end
end
