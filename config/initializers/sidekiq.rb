#
# Sidekiq setup
# see https://github.com/mperham/sidekiq/wiki/Advanced-Options
#

Sidekiq::Logging.logger = Rails.logger

# We have workers that enqueue other jobs; need the client stuff everywhere
require 'sidekiq/pro/reliable_push'
require './config/clock.rb'
require './lib/clockwork/sidekiq_clockwork_scheduler.rb'
require './config/initializers/yakety_yak'

default=Xact::Application.config.sidekiq[:default]

class Sidekiq::Middleware::Server::LogAllTheThings
  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def call(worker, job, queue)
    logger.info("Invoking job: #{job.inspect}")
    yield
  end
end


Sidekiq.configure_server do |config|
  require 'sidekiq/pro/reliable_fetch'

  config.redis = default.merge(Xact::Application.config.sidekiq[:server])
  config.options[:concurrency] = 30
  config.options[:queues] = ['sender', 'default', 'command', 'webhook', 'stats']
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::LogAllTheThings, Rails.logger
    chain.add Sidekiq::Throttler, storage: :redis
  end
  SidekiqClockworkScheduler.new.async.run

  if Rails.configuration.analytics[:enabled]
    YaketyYak::Subscriber::Supervisor.go!
  else
    warn('YaketyYak analytics are disabled')
  end
  Rails.logger.info "Background services have started."
end


Sidekiq.configure_client do |config|
  config.redis = default.merge(Xact::Application.config.sidekiq[:client])
end

Sidekiq::Web.app_url = '/'
