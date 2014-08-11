require "sidekiq/retries/version"
require 'sidekiq/retries/server/middleware'
require 'sidekiq/retries/errors'

Sidekiq.configure_server do |config|
  require 'sidekiq/middleware/server/retry_jobs'
  require 'sidekiq/retries/server/middleware'

  stock_middleware = Sidekiq::Middleware::Server::RetryJobs

  config.server_middleware do |chain|
    chain.insert_before stock_middleware, Sidekiq::Retries::Server::Middleware
    chain.remove stock_middleware
  end
end
