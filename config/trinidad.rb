require 'bundler/setup'
Trinidad.configure do |config|
  config.jruby_min_runtimes = 1
  config.jruby_max_runtimes = 1
  config.extensions = {:scheduler=>nil}
  config.http = {
    :acceptCount  => 100,
    :maxThreads  => 20,
    :maxKeepAliveRequests  => 100
  }
end