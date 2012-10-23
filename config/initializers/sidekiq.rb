#
# Sidekiq setup
# see https://github.com/mperham/sidekiq/wiki/Advanced-Options
#
default=Tsms::Application.config.sidekiq[:default]

Sidekiq.configure_server do |config|
  config.redis = default.merge(Tsms::Application.config.sidekiq[:server])
end

# Running in passenger - connect after fork
# https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Sidekiq.configure_client do |config|
      config.redis = default.merge(Tsms::Application.config.sidekiq[:client])
    end if forked
  end
# non-passenger client mode
else 
  Sidekiq.configure_client do |config|
    config.redis = default.merge(Tsms::Application.config.sidekiq[:client])
  end
end