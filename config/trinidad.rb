require 'bundler/setup'

Trinidad.configure do |config|
  ##
  # Here we are loading the database.yml file and 
  # parsing out some variables. THis allows us 
  # to use in the Java-managed database connection pool 
  #
  db_yaml       = YAML.load_file('config/database.yml')
  configuration = db_yaml[(ENV['RAILS_ENV'] || 'development')]
  database      = configuration["database"]
  username      = configuration["username"]
  password      = configuration["password"]

  config.jruby_min_runtimes = 1
  config.jruby_max_runtimes = 1
  config.extensions = {
    :scheduler=>nil
  }
  config.extensions[:oracle_dbpool] = {
    jndi: 'jdbc/xact', # this should be the same as what is in database.yml
    url: "jdbc:oracle:thin:@//#{database}", # expected to be 'host.gdi:port/service_name'
    username: username,
    password: password,
    maxActive: 10,
    maxIdle: 10,
    maxWait: 10,
    accessToUnderlyingConnectionAllowed: true
  }
  config.http = {
    :acceptCount  => 100,
    :maxThreads  => 20,
    :maxKeepAliveRequests  => 100
  }
end