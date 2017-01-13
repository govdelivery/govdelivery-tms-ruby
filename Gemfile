source 'https://rubygems.org'

source 'http://prod-rubygems1-ep.tops.gdi/' do
  group :test do
    gem 'cuke_sniffer', '0.0.8.ruleConfig5'
  end

  gem 'brick'
  gem 'config_spartan', '~>1.0.0'
  gem 'govdelivery-crypt', require: 'govdelivery/crypt'
  platforms :jruby do
    gem 'govdelivery-kahlo'
  end
  gem 'govdelivery-links'
end

gem 'dcm_client'
gem 'aasm'
gem 'activerecord-oracle_enhanced-adapter', "~>1.6.7"
gem 'addressable'
gem 'celluloid'
gem 'clockwork'
gem 'devise'
gem 'enumify'
gem 'faraday'
gem 'faraday_middleware'
gem 'kaminari'
gem 'liquid', '<4.0'
gem 'log4r'
gem 'newrelic_rpm'
gem 'phony'
gem 'phony_rails'
gem 'protected_attributes'
gem 'rabl'
gem 'rack-ssl'
gem 'rake', '<12.0.0'
gem 'rails', '~>4.2.6'
gem 'rails-api'
gem 'redis'
gem 'redis-activesupport'
gem 'redis-rails'
gem 'redis-store'
gem 'request_exception_handler'
gem 'responders'
gem 'send_nsca'
gem 'sidekiq'
gem 'sidekiq-pro', source: 'https://9954a10b:3891f6a5@gems.contribsys.com/'
gem 'sidekiq-retries'
gem 'sidekiq-unique-jobs'
gem 'simple_token_authentication', "=1.5.1"
gem 'sinatra', require: nil
gem 'slim'
gem 'strip_attributes'
gem 'twilio-ruby'
gem 'valid_email'
gem 'validate_url'

gem 'attr_encrypted', '=1.4.0'

gem 'govdelivery-dbtasks', git: 'http://dev-scm.office.gdi/development/govdelivery-dbtasks.git', ref: 'v0.4.5' #this needs to come after oracle_enhanced
gem 'govdelivery-health_check', git: 'http://dev-scm.office.gdi/development/govdelivery-health_check.git'

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'lock_jar', '>= 0.8.0'
  gem 'trinidad', require: nil
  gem 'jruby-openssl', "=0.9.17"
end

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman-min'
  gem 'capybara'
  gem 'colored'
  gem 'cucumber'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'highline' # for brakeman
  gem 'httpi', '2.1.0'
  gem 'json'
  gem 'json_spec'
  gem 'mechanize'
  gem 'multi_xml'
  gem 'nokogiri'
  gem 'poltergeist'
  gem 'rspec-collection_matchers'
  gem 'rspec-its', '~> 1.2.0'
  gem 'rspec-rails', '~> 3.1.0'
  gem 'yaml_db'
end

group :development do
  gem 'alphabetize'
  gem 'rails-erd'
end

group :development, :test do
  gem 'rubocop'
  gem 'rubocop-checkstyle_formatter', require: false
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-nav'
end

group :test do
  gem 'govdelivery-tms', '~>0.10.0'
  gem 'govdelivery-tms-internal', '~>0.0.2'
  gem 'configatron'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'fakeweb'
  gem 'mocha', require: false
  gem 'shoulda-matchers', '<3'
  gem 'govdelivery-proctor', '>=1.3.1'
end
