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
gem "strip_attributes"
gem 'attr_encrypted'
gem 'activerecord-oracle_enhanced-adapter', '=1.4.1.4'
gem 'valid_email'
gem 'newrelic_rpm'
gem 'request_exception_handler'

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'jbundler'
  gem 'trinidad', :require => nil
  gem 'trinidad_scheduler_extension'
  gem 'trinidad_oracle_dbpool_extension'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'json_spec'
  gem 'guard-rspec'
  platforms :ruby do
    gem 'sqlite3'
    gem 'pry-debugger', require: 'pry'
  end
  gem 'pry', require: 'pry'
end

group :development do
  gem 'rails-erd'  
end

group :test do
  gem 'mocha', :require => false
  gem 'tms_client', :git => 'https://github.com/govdelivery/tms_client.git', :ref => '73ede269bb71' # work needed to update
end

platforms :ruby do
  group :development, :test do
    gem 'zeus'
  end
end

platforms :ruby do
  group :development, :test do
    gem 'zeus'
  end
end
