Xact::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.eager_load = false

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.odm_host = "http://nowhere:65080"
  config.odm_endpoint = "#{config.odm_host}/service/TMSExtended?wsdl"
  config.odm_username = 'doesnt'
  config.odm_password = 'matter'

  # Used to determine whether to send the callback_url parameter when sending
  # a SMS Message.  We don't want to send a callback_url parameter when the application
  # is not accessible from the internet.
  config.public_callback = false  

  # Used for forwarding STOP requests for short codes that are shared between
  # XACT and DCM (GOV311) - XACT-175
  config.dcm_urls = []
  config.shared_phone_numbers = []

  config.fema_url = 'https://tdl.integration.fema.gov/IPAWS_CAPService/IPAWS'

  Rails.logger.level = Log4r::DEBUG
end
