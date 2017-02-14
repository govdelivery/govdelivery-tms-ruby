#
# Sidekiq setup
# see https://github.com/mperham/sidekiq/wiki/Advanced-Options
#

Sidekiq::Logging.logger = Rails.logger
Sidekiq::Client.reliable_push!

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

if Socket.gethostname.match(/bg[12]/) # concurrency and queue config based on RUN-4796
  concurrency = 10
  queues = %w(webhook default stats low)
else # bg3,bg4 in lower envs, bg3-6 in prod.
  concurrency = 20
  queues = %w(sender recipient)
end

Sidekiq.configure_server do |config|

  config.reliable_fetch!

  config.redis                 = default.merge(Xact::Application.config.sidekiq[:server])
  config.options[:concurrency] = concurrency
  config.options[:queues]      = queues
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::LogAllTheThings, Rails.logger
  end

  require './config/clock.rb'
  require './lib/clockwork/sidekiq_clockwork_scheduler.rb'
  SidekiqClockworkScheduler.new.async.run

  if Conf.analytics_enabled
    require 'sidekiq/synapse'
    require 'rjack-slf4j/log4j12'
    Synapse::Supervisor.go!
  else
    warn('Synapse::Supervisor not started')
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

