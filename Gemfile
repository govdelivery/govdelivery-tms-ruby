source 'https://rubygems.org'

source 'https://ed5779be:de10e893@gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

source 'http://prod-rubygems1-ep.tops.gdi' do
  gem 'config_spartan', '~>1.0.0'
  gem 'dcm_client'
  gem 'govdelivery-crypt', require: 'govdelivery/crypt'
  gem 'govdelivery-dbtasks'
  gem 'govdelivery-links'
  gem 'jakety_jak', '~>1.1.0', require: nil
  gem 'brick'
end

gem 'aasm'
gem 'activerecord-oracle_enhanced-adapter', git: 'git@github.com:rsim/oracle-enhanced.git', branch: 'release15'
gem 'addressable'
gem 'celluloid'
gem 'clockwork'
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
gem 'rails', '~>4.1.0'
gem 'rails-api'
gem 'redis'
gem 'redis-activesupport'
gem 'redis-rails'
gem 'redis-store', '=1.1.4'
gem 'request_exception_handler'
gem 'rjack-slf4j'
gem 'send_nsca'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidekiq-retries'
gem 'sidekiq-unique-jobs'
gem 'simple_token_authentication'
gem 'sinatra', require: nil
gem 'slim'
gem 'strip_attributes'
gem 'twilio-ruby'
gem 'valid_email'
gem 'validate_url'
gem 'yakety_yak'

gem 'attr_encrypted'

platforms :ruby do
  gem 'ruby-oci8'
end

platforms :jruby do
  gem 'lock_jar', '>= 0.8.0'
  gem 'trinidad', require: nil
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
  gem 'rspec-its'
  gem 'rspec-rails'
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
end

group :test do
  source 'http://prod-rubygems1-ep.tops.gdi' do
    gem 'govdelivery-tms', '~>0.8.2'
    gem 'govdelivery-tms-internal', '~>0.0.2'
  end
  gem 'configatron'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'fakeweb'
  gem 'mocha', require: false
  gem 'shoulda-matchers'
end
