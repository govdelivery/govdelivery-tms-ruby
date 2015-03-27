# Set this before connecting to the database
ENV['NLS_LANG'] = 'american_america.AL32UTF8'
$CLASSPATH << File.expand_path("../../config", __FILE__) # Rails.root.join('config/').to_s

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/ssl'

# set up logging
require File.expand_path("../logging", __FILE__)

require File.join(File.expand_path("../../lib", __FILE__), 'gov_delivery', 'host')

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end
Encoding.default_internal = Encoding.default_external = Encoding::UTF_8

I18n.enforce_available_locales = true

module Xact
  class Application < Rails::Application
    ::Conf = ConfigSpartan.create do
      file "config/config.yml"
      file "config/config.local.yml"
      file "config/config.test.yml" if Rails.env.test?
      file "/etc/sysconfig/xact.yml"
    end

    config.eager_load = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << Rails.root.join('app', 'workers')
    config.autoload_paths << Rails.root.join('app', 'presenters')
    config.autoload_paths << Rails.root.join('lib')

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding                                    = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters                           += [:password, :auth_token]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled                              = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version                              = '1.0'

    # This is only used to write urls
    config.protocol                                    = 'https'

    # Bring in a couple of middlewares excluded by rails-api but needed for warden/devise
    # Rack::SSL has to come before ActionDispatch::Cookies!
    config.middleware.use Rack::SSL, exclude: lambda { |env| !Rack::Request.new(env).ssl? }
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    redis_opts = {url: Conf.redis_uri}

    if Conf.redis_sentinel_uris.any?
      redis_opts[:sentinels] = Conf.redis_sentinel_uris.map { |sentinel| {host: sentinel.host, port: sentinel.port.to_i} }
    end

    config.cache_store = :redis_store, redis_opts, {pool_size: 7}

    # see https://github.com/mperham/sidekiq/wiki/Advanced-Options
    config.sidekiq                = {
      default: {namespace: 'xact'}.merge!(redis_opts),
      client:  {size: 20},
      server:  {}
    }

    # ODM stats jobs fetch content in batches of this size
    config.odm_stats_batch_size   = 500

    # Messages sent via Twilio that we haven't heard back about should be finalized
    config.twilio_minimum_polling_age = 1.hour
    config.twilio_delivery_timeout    = 4.hours
    config.email_delivery_timeout = 24.hours

    config.dcm = {
      username: Conf.dcm_username,
      password: Conf.dcm_password,
      api_root: Conf.dcm_uri
    }

    config.twilio_polling_enabled = true
    config.odm_polling_enabled    = true
    config.colorize_logging       = false

    config.fema_url            = Conf.fema_uri

    # qc ODM
    config.odm_endpoint        = "#{Conf.odm_uri}/service/TMSExtended?wsdl"
    config.odm_username        = Conf.odm_username
    config.odm_password        = Conf.odm_password

    # override Rack exception application handling of exception status codes
    config.exceptions_app      = self.routes

    routes.default_url_options     = {host: "#{Rails.env.to_s}-tms.govdelivery.com", protocol: 'https'}

    # Threshold (in minutes) under which multiple inbound messages from a
    # user will be ignored.  This is to prevent auto-response messages
    # (as sometimes issued from handsets while people are driving) from entering an infinite
    # loop.  The corresponding configuration for this value in
    # DCM is "twilio_requests_timeout."  Here it is named differently,
    # as this is not a vendor-specific behavior.
    config.auto_response_threshold = 0.5

    # Controls whether this environment will publish/subscribe to Kafka
    config.analytics               = {
      enabled:    Conf.analytics_enabled,
      kafkas:     Conf.analytics_kafkas,
      zookeepers: Conf.analytics_zookeepers
    }

    # Default log level is DEBUG
    config.logger    = Rails.logger = ActiveRecord::Base.logger = Log4r::Logger['default']

    host                       = GovDelivery::Host.new
    config.datacenter_location = host.datacenter
    config.datacenter_env      = host.env
    config.nsca_password       = Conf.nsca_password

    config.custom_report_account_id = ENV['XACT_CUSTOM_REPORT_ACCOUNT_ID']
  end
end
