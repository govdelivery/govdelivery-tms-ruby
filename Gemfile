source "http://prod-rubygems1-ep.tops.gdi"
source "https://ed5779be:de10e893@www.mikeperham.com/rubygems/"
source 'https://rubygems.org'

gem 'aasm'
gem 'addressable'
gem 'activerecord-oracle_enhanced-adapter', '=1.5.5.3'
gem 'clockwork'
gem 'dcm_client'
gem 'devise'
gem 'enumify'
gem 'faraday'
gem 'faraday_middleware'
gem 'kaminari'
gem 'log4r'
gem 'newrelic_rpm'
gem 'phony'
gem 'phony_rails'
gem 'protected_attributes'
gem 'rabl'
gem 'rack-ssl'
gem 'rails', '~>4.0'
gem 'rails-api'
gem 'redis-rails'
gem 'redis-store', '=1.1.4'
gem 'redis-activesupport', '=4.0.0.2'
gem 'request_exception_handler'
gem 'sidekiq-failures'
gem 'sidekiq-pro'
gem 'sidekiq-retries'
gem 'sidekiq-throttler'
gem 'sidekiq-unique-jobs'
gem 'simple_token_authentication'
gem 'sinatra', :require => nil
gem 'slim'
gem "strip_attributes"
gem 'twilio-ruby'
gem "validate_url"
gem 'valid_email'
gem 'yakety_yak'
gem 'attr_encrypted'

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'lock_jar', '>= 0.8.0'
  gem 'trinidad', :require => nil
end

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman'
  gem 'capybara'
  gem 'colored'
  gem 'cucumber'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'httpi', '2.1.0'
  gem 'json'
  gem 'json_spec'
  gem 'mail'
  gem 'mechanize'
  gem 'nokogiri'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'pry'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'ruby-debug'
  gem 'yaml_db'

  platforms :ruby do
    gem 'pry-debugger', require: 'pry'
    gem 'zeus'
  end
end

group :development do
  gem 'alphabetize'
  gem 'rails-erd'
end

group :test do
  gem "fakeredis", :require => "fakeredis/rspec"
  gem 'mocha', :require => false
  gem 'shoulda-matchers'
  gem 'tms_client'
end

