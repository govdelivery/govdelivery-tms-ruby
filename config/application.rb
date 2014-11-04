# Set this before connecting to the database
ENV['NLS_LANG'] = 'american_america.AL32UTF8'

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/ssl'

# set up logging
require File.expand_path("../logging", __FILE__)

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
    config.eager_load = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << Rails.root.join('app', 'workers')
    config.autoload_paths << Rails.root.join('app', 'presenters')
    config.autoload_paths << Rails.root.join('app', 'transformers')
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


    config.cache_store            = :redis_store, ENV['REDIS_URI'], {pool_size: 7}

    # see https://github.com/mperham/sidekiq/wiki/Advanced-Options
    config.sidekiq                = {
      default: {
        url:       ENV['REDIS_URI'],
        namespace: 'xact'
      },
      client:  {size: 20},
      server:  {}
    }

    # ODM stats jobs fetch content in batches of this size
    config.odm_stats_batch_size   = 500

    # Twilio test credentials
    config.twilio_test_username   = ENV['TWILIO_TEST_SID']
    config.twilio_test_password   = ENV['TWILIO_TEST_TOKEN']

    # Messages sent via Twilio that we haven't heard back about should be finalized
    config.min_twilio_polling_age = '24.hours'
    config.max_twilio_polling_age = '72.hours'

    config.dcm = [{
                    username: ENV['DCM_USERNAME'],
                    password: ENV['DCM_PASSWORD'],
                    api_root: ENV['DCM_URI']
                  }]

    config.twilio_polling_enabled = true
    config.odm_polling_enabled    = true
    config.colorize_logging       = false

    config.twilio_username = ENV['TWILIO_SID']
    config.twilio_password = ENV['TWILIO_TOKEN']
    config.twilio_number   = ENV['TWILIO_NUMBER']

    config.fema_url            = ENV['FEMA_URI']

    # qc ODM
    config.odm_polling_enabled = false
    config.odm_endpoint        = ENV['ODM_URI']
    config.odm_username        = ENV['ODM_USERNAME']
    config.odm_password        = ENV['ODM_PASSWORD']

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
      enabled:    ENV['ANALYTICS_ENABLED']=='true',
      kafkas:     ENV['ANALYTICS_KAFKAS'].split(','),
      zookeepers: ENV['ANALYTICS_ZOOKEEPERS'].split(','),
    }

    # Default log level is INFO
    config.logger                  = Rails.logger = ActiveRecord::Base.logger = Log4r::Logger['default']
    Rails.logger.level             = Log4r::INFO

    config.default_message_timeout = 2.days
  end
end
