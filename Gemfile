source "http://prod-rubygems1-ep.tops.gdi"
source 'https://rubygems.org'
source "http://ed5779be:de10e893@www.mikeperham.com/rubygems/"

gem 'sinatra', :require => nil
gem 'rails', '~>3.2.13'
gem 'rails-api'
gem 'redis-store', '=1.1.3' # 1.1.4 has breaking changes
gem 'redis-rails'
gem 'sidekiq-pro'
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
gem 'typhoeus'
gem 'faraday'
gem 'faraday_middleware'
gem 'dcm_client', '~>0.1.4'
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
    gem 'zeus'
    gem 'pry-debugger', require: 'pry'
  end
  platforms :jruby do
    gem 'jbundler'
  end
  gem 'pry', require: 'pry'
end

group :development do
  gem 'rails-erd'  
end

group :test do
  gem 'mocha', :require => false
  gem 'tms_client'
end
