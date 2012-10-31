source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'rails-api'


gem 'json'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'sidekiq'
gem 'twilio-ruby'
gem 'rabl'
gem 'kaminari'

group 'oracle' do
  gem 'ruby-oci8'
  gem 'activerecord-oracle_enhanced-adapter'
end


gem 'log4r'
gem 'devise'

group :test do
  gem 'mocha', :require=>false
end


group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'sqlite3'
  gem 'pry'
end
