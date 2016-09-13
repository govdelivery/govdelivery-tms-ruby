# Controls whether this environment will publish/subscribe to Kafka
if Conf.analytics_enabled

  ::Synapse.configure do |config|
    config.source          = 'xact'
    config.schema_registry = Conf.analytics_schema_registry_url
    config.kafkas          = Conf.analytics_kafkas.join(',')
    config.client_id       = "#{Socket.gethostname}-#{Process.pid}"
  end

else
  warn('analytics_enabled is false')
end

