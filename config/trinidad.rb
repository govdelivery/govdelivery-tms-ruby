require 'bundler/setup'
Trinidad.configure do |config|
  config.jruby_min_runtimes = 1
  config.jruby_max_runtimes = 1
end