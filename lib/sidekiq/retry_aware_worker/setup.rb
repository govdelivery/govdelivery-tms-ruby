Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::RetryAwareWorker::Middleware
  end
end
Sidekiq::Worker.send(:include, Sidekiq::RetryAwareWorker::Worker)
