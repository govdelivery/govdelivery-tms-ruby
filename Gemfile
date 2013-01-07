source "http://buildbox.office.gdi:6789"
source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'rails-api'
gem 'redis-rails'
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

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'jbundler'
  gem 'trinidad', :require => nil
end

gem 'activerecord-oracle_enhanced-adapter'
gem 'attr_encrypted'

group :test do
  gem 'mocha', :require=>false
  gem 'pry'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  platforms :ruby do
    gem 'sqlite3'
  end
  gem 'pry'
end

group :development do
  gem 'rails-erd'
end