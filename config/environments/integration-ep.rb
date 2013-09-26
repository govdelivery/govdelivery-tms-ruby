Xact::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production

  config.redis_url = 'redis://int-xactredis-master-ep.tops.gdi:6379'
  config.cache_store = :redis_store, config.redis_url

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # https://github.com/rails/rails/issues/2662
  config.threadsafe! unless $rails_rake_task

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.twilio_username = 'AC189315456a80a4d1d4f82f4a732ad77e'
  config.twilio_password = '88e3775ad71e487c7c90b848a55a5c88'
  config.twilio_number   = '+19138719228'

  config.sidekiq[:server][:url] = "#{config.redis_url}/1"
  config.sidekiq[:client][:url] = "#{config.redis_url}/1"

  config.dcm = [
    {
      username: 'xact-api@govdelivery.com',
      password: "let's do Ortega Bombs",
      api_root: 'https://int-api-dc2.govdelivery.com' 
    },
    {
      username: 'xact-api@govdelivery.com',
      password: "let's do Ortega Bombs",
      api_root: 'https://int-api.govdelivery.com' 
    }
  ]

  config.odm_polling_enabled = true
  config.odm_host = "https://int-tms-dc2.govdelivery.com:65081"
  config.odm_endpoint = "#{config.odm_host}/service/TMSExtended"
  config.odm_username = 'xact'
  config.odm_password = 'Eish8sai2Heofereekae5ohmiyeijiN'
  
  # Used to determine whether to send the callback_url parameter when sending
  # a SMS Message.  We don't want to send a callback_url parameter when the application
  # is not accessible from the internet.
  config.public_callback = true  
end
