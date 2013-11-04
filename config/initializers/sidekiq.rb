#
# Sidekiq setup
# see https://github.com/mperham/sidekiq/wiki/Advanced-Options
#

# We have workers that enqueue other jobs; need the client stuff everywhere
require 'sidekiq/pro/reliable_push'

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

Sidekiq::Logging.logger = Rails.logger

Sidekiq.configure_server do |config|
  require 'sidekiq/pro/reliable_fetch'

  config.redis = default.merge(Xact::Application.config.sidekiq[:server])
  config.options[:concurrency] = 10
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::LogAllTheThings, Rails.logger
    # remove the default logging middleware because it assumes the worker name
    # is already in the logger string.
    chain.remove Sidekiq::Middleware::Server::Logging
  end
end

Sidekiq.configure_client do |config|
  config.redis = default.merge(Xact::Application.config.sidekiq[:client])
end
