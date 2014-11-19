Xact::Application.configure do
  config.eager_load = false
  config.cache_classes = true

  config.whiny_nils = true

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true

  config.redis_url = 'redis://it-buildbox1.office.gdi:6379'

  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Used to determine whether to send the callback_url parameter when sending
  # a SMS Message.  We don't want to send a callback_url parameter when the application
  # is not accessible from the internet.
  config.public_callback = false

  routes.default_url_options = {host: 'test.host', port: 3000}

  # Used for forwarding STOP requests for short codes that are shared between
  # XACT and DCM (GOV311) - XACT-175
  config.shared_phone_numbers = []

  config.sidekiq = {
    default: {
      url:       "redis://it-buildbox1.office.gdi:6379/2",
      namespace: 'xact'
    },
    client:  {size: 20},
    server:  {}
  }
end
