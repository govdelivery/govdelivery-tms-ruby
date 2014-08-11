source "http://prod-rubygems1-ep.tops.gdi"
source 'https://rubygems.org'
source "https://ed5779be:de10e893@www.mikeperham.com/rubygems/"

gem 'sinatra', :require => nil
gem 'rails', '~>4.0'
gem 'rails-api'
gem 'redis-store', '=1.1.3' # 1.1.4 has breaking changes
gem 'redis-rails'
gem 'sidekiq-pro'
gem 'sidekiq-retries', git: 'https://github.com/govdelivery/sidekiq-retries.git'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs'
gem 'twilio-ruby'
gem 'rabl'
gem 'kaminari'
gem 'log4r'
gem 'devise'
gem 'phony'
gem 'phony_rails'
gem 'protected_attributes'
gem 'slim'
gem 'typhoeus'
gem 'faraday'
gem 'faraday_middleware'
gem 'dcm_client', '~>0.1.4'
gem 'enumify'
gem "strip_attributes"
gem 'attr_encrypted'
gem 'activerecord-oracle_enhanced-adapter' #, '=1.4.3.5'
gem 'valid_email'
gem 'newrelic_rpm'
gem 'request_exception_handler'
gem 'clockwork'
gem 'simple_token_authentication'
gem 'yakety_yak'

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'lock_jar', '>= 0.8.0'
  gem 'trinidad', :require => nil
  gem 'trinidad_generic_dbpool_extension'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'factory_girl_rails'
  gem 'json_spec'
  gem 'guard-rspec'
  platforms :ruby do
    gem 'zeus'
    gem 'pry-debugger', require: 'pry'
  end
  gem 'pry-rails'
  gem 'pry', github: 'pry/pry'
  gem 'ruby-debug'
  gem 'brakeman'
  gem 'yaml_db'
end

group :development do
  gem 'rails-erd'
end

group :test do
  gem "fakeredis", :require => "fakeredis/rspec"
  gem 'mocha', :require => false
  gem 'tms_client'
  gem 'shoulda-matchers'
end
