# Be sure to restart your server when you modify this file.

Xact::Application.config.session_store :active_record_store, {
  :key => '_session_id',
  :secure => !['test', 'development'].include?(Rails.env),
  :expire_after =>  2.hours
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Xact::Application.config.session_store :active_record_store

ActiveRecord::SessionStore::Session.attr_accessible :data, :session_id

# needed for using the activerecord-session_store gem, which we use to store sessions in our one time session token authentication. See https://github.com/rails/activerecord-session_store
Log4r::Logger.send :include, ActiveRecord::SessionStore::Extension::LoggerSilencer
