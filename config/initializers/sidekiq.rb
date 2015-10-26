#
# Sidekiq setup
# see https://github.com/mperham/sidekiq/wiki/Advanced-Options
#

Sidekiq::Logging.logger = Rails.logger
Sidekiq::Client.reliable_push!

# We have workers that enqueue other jobs; need the client stuff everywhere
require './config/clock.rb'
require './lib/clockwork/sidekiq_clockwork_scheduler.rb'
require './config/initializers/yakety_yak'

default = Xact::Application.config.sidekiq[:default]

class Sidekiq::Middleware::Server::LogAllTheThings
  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def call(_worker, job, _queue)
    logger.info("Invoking job: #{job.inspect}")
    yield
  end
end

Sidekiq.configure_server do |config|
  config.reliable_fetch!

  config.redis                 = default.merge(Xact::Application.config.sidekiq[:server])
  config.options[:concurrency] = 30
  config.options[:queues]      = %w(sender default webhook stats low)
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::LogAllTheThings, Rails.logger
  end
  SidekiqClockworkScheduler.new.async.run

  if Rails.configuration.analytics[:enabled]
    require 'rjack-slf4j/log4j12'
    JaketyJak::Subscriber::Supervisor.go!
  else
    warn('JaketyJak analytics are disabled')
  end

  Sidekiq::RateLimitedQueue::Configuration.load!(Rails.root.join('config', 'sidekiq_rate_limited_queues.yml'))

  Rails.logger.info 'Background services have started.'
end

require 'sidekiq/dynamic_queue/setup'
require 'sidekiq/rate_limited_queue/setup'
require 'sidekiq/retry_aware_worker/setup'

Sidekiq.configure_client do |config|
  config.redis = default.merge(Xact::Application.config.sidekiq[:client])
end

SidekiqUniqueJobs.config.unique_args_enabled = true
SidekiqUniqueJobs.config.unique_storage_method = :old

Sidekiq::Web.app_url = '/'
