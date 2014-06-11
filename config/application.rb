# Set this before connecting to the database
ENV['NLS_LANG'] = 'american_america.AL32UTF8'

require File.expand_path('../boot', __FILE__)

require 'rails/all'

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
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << Rails.root.join('app', 'workers')

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
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :auth_token]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # This is only used to write urls 
    config.protocol = 'https'

    # Bring in a couple of middlewares excluded by rails-api but needed for warden/devise
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    redis_config = YAML::load_file(Rails.root.join('config/redis.yml'))[Rails.env]
    config.cache_store = :redis_store, redis_config['url']

    # see https://github.com/mperham/sidekiq/wiki/Advanced-Options
    config.sidekiq = {
      default: {
        url: "#{redis_config['url']}/#{redis_config['sidekiq_db']}",
        namespace: redis_config['sidekiq_namespace']
      },
      client: {size: 20},
      server: {}
    }

    # ODM stats jobs fetch content in batches of this size
    config.odm_stats_batch_size = 500

    # Messages sent via Twilio that we haven't heard back about should be finalized
    config.min_twilio_polling_age = '24.hours'
    config.max_twilio_polling_age = '72.hours'

    config.dcm = [{
      username: 'product@govdelivery.com',
      password: 'retek01!',
      api_root: 'http://evolution.local:3001'
    }]

    config.twilio_polling_enabled = true
    config.odm_polling_enabled = true
    config.colorize_logging = false

    # override Rack exception application handling of exception status codes
    config.exceptions_app = self.routes

    # Threshold (in minutes) under which multiple inbound messages from a 
    # user will be ignored.  This is to prevent auto-response messages 
    # (as sometimes issued from handsets while people are driving) from entering an infinite
    # loop.  The corresponding configuration for this value in 
    # DCM is "twilio_requests_timeout."  Here it is named differently,
    # as this is not a vendor-specific behavior.
    config.auto_response_threshold = 0.5

    # Default log level is INFO
    config.logger =
      Rails.logger =
      ActiveRecord::Base.logger =
        Log4r::Logger['default']
    Rails.logger.level = Log4r::INFO
  end
end
