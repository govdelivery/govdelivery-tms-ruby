source "http://buildbox.office.gdi:6789"
source 'https://rubygems.org'

gem 'rails'
gem 'rails-api'
gem 'redis-rails'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs'
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
gem 'enumify'

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'jbundler'
  gem 'trinidad', :require => nil
  gem 'trinidad_jmx_remote_extension', :require => false
  gem 'trinidad_scheduler_extension'
end

gem 'activerecord-oracle_enhanced-adapter'
gem 'attr_encrypted'

group :test do
  gem 'mocha', :require => false
  gem 'pry'
  gem 'tms_client', :git => 'https://github.com/govdelivery/tms_client.git'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'json_spec'
  gem 'guard-rspec'
  platforms :ruby do
    gem 'sqlite3'
  end
  gem 'pry'
end

group :development do
  gem 'rails-erd'
end
