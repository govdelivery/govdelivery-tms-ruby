Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::DynamicQueue::Middleware::Client
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::DynamicQueue::Middleware::Client
  end
end
