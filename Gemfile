source "http://buildbox.office.gdi:6789"
source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'rails-api'
gem 'sidekiq'
gem 'twilio-ruby'
gem 'rabl'
gem 'kaminari'
gem 'log4r'
gem 'devise'
gem 'phony'
gem 'phony_rails' 
gem 'slim'
gem 'sinatra', :require => nil
gem 'typhoeus'
gem 'faraday'
gem 'faraday_middleware'
gem 'dcm_client'
gem 'ruby-oci8'
gem 'activerecord-oracle_enhanced-adapter'

group :test do
  gem 'mocha', :require=>false
  gem 'pry'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'sqlite3'
  gem 'pry'
end

group :development do
  gem 'rails-erd'
end