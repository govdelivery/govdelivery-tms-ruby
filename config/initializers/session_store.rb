# Be sure to restart your server when you modify this file.

Xact::Application.config.session_store :active_record_store, {
  :key => '_session_id',
  :secure => !['test', 'development'].include?(Rails.env),
  # TODO: how long should we wait to expire a session?
  :expire_after =>  nil
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Xact::Application.config.session_store :active_record_store
