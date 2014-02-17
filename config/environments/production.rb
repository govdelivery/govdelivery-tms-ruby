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
  # Rails.logger.level = Log4r::DEBUG
  
  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production

  config.redis_url = 'redis://prod-xactredis-master-ep.tops.gdi:6379'
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

  config.twilio_username = 'ACcc41a7e742457806f26d91a1ea19de9f'
  config.twilio_password = '331b3a44b5067a3c02013a6cfaa18b1c'
  config.twilio_number   = '+16514336311'

  config.sidekiq[:server][:url] = "#{config.redis_url}/1"
  config.sidekiq[:client][:url] = "#{config.redis_url}/1"

  config.dcm = [
    {
      username: 'xact-api@govdelivery.com',
      password: 'BV&f3dS3^PRntHeT&0xekwko%4nJo#PO',
      api_root: 'https://api.govdelivery.com'
    }
  ]

  config.odm_host     = "https://tms.govdelivery.com:65081"
  config.odm_endpoint = "#{config.odm_host}/service/TMSExtended?wsdl"
  config.odm_username = 'xact'
  config.odm_password = 'phystondusonujocrazendehifreri'

  # Used to determine whether to send the callback_url parameter when sending
  # a SMS Message.  We don't want to send a callback_url parameter when the application
  # is not accessible from the internet.
  config.public_callback = true  

  # Used for forwarding STOP requests for short codes that are shared between
  # XACT and DCM (GOV311) - XACT-175
  config.shared_phone_numbers = ["468311"]

  config.custom_report_account_id = 10060
end
