Xact::Application.configure do
  config.cache_classes = true

  config.whiny_nils = true

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true

  config.redis_url = 'redis://qc-redis-master.visi.gdi:6379'
  config.cache_store = :redis_store, config.redis_url

  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.twilio_username = 'ACcc41a7e742457806f26d91a1ea19de9f'
  config.twilio_password = '331b3a44b5067a3c02013a6cfaa18b1c'
  config.twilio_number = '(651) 433-6311'

  config.sidekiq[:server][:url] = "#{config.redis_url}/2"
  config.sidekiq[:client][:url] = "#{config.redis_url}/2"

  # qc ODM
  config.odm_host = "http://qc-tms1.visi.gdi:65080"
  config.odm_endpoint = "#{config.odm_host}/service/TMSExtended"
  config.odm_username = 'gd3'
  config.odm_password = 'R0WG38piNv5NRK0DT8mq04fU'

  # Used to determine whether to send the callback_url parameter when sending
  # a SMS Message.  We don't want to send a callback_url parameter when the application
  # is not accessible from the internet.
  config.public_callback = false
end