Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::RateLimitedQueue::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add Sidekiq::RateLimitedQueue::Middleware::Client
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::RateLimitedQueue::Middleware::Client
  end
end
