#
# Sidekiq setup
# see https://github.com/mperham/sidekiq/wiki/Advanced-Options
#
default=Xact::Application.config.sidekiq[:default]

Sidekiq.configure_server do |config|
  require 'sidekiq/pro/reliable_fetch'
  config.redis = default.merge(Xact::Application.config.sidekiq[:server])
  config.options[:concurrency] = 10
end

# Running in passenger - connect after fork
# https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Sidekiq.configure_client do |config|
      require 'sidekiq/pro/reliable_push'
      config.redis = default.merge(Xact::Application.config.sidekiq[:client])
    end if forked
  end
# non-passenger client mode
else 
  Sidekiq.configure_client do |config|
    require 'sidekiq/pro/reliable_push'
    config.redis = default.merge(Xact::Application.config.sidekiq[:client])
  end
end
