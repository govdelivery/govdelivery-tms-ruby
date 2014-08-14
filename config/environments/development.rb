Xact::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # This is only used to write urls
  config.protocol = 'http'

  routes.default_url_options = {host: 'localhost', port: 3000, protocol: config.protocol}

  # Expands the lines which load the assets
  config.assets.debug = true

  config.twilio_username = 'ACcc41a7e742457806f26d91a1ea19de9f'
  config.twilio_password = '331b3a44b5067a3c02013a6cfaa18b1c'
  config.twilio_number = '+16514336311'

  # qc ODM
  config.odm_host = "http://localhost:65080"
  config.odm_endpoint = "#{config.odm_host}/service/TMSExtended?wsdl"
  config.odm_username = 'gd3'
  config.odm_password = 'R0WG38piNv5NRK0DT8mq04fU'
  
  # Used to determine whether to send the callback_url parameter when sending
  # a SMS Message.  We don't want to send a callback_url parameter when the application
  # is not accessible from the internet.
  config.public_callback = false

  # Used for forwarding STOP requests for short codes that are shared between
  # XACT and DCM (GOV311) - XACT-175
  config.shared_phone_numbers = ['+16514336311']

  config.fema_url = 'https://tdl.integration.fema.gov/IPAWS_CAPService/IPAWS'

  Rails.logger.level = Log4r::DEBUG
end
