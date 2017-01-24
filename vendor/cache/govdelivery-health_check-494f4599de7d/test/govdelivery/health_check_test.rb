require 'test_helper'
require 'minitest/pride'
require 'fileutils'
require 'rack/test'

class CustomCheck < GovDelivery::HealthCheck::Checks::Base
  def check!
    fatal!("CustomCheck: fatal!") if params[:fatal]
    warn!("CustomCheck: warn!") if params[:warn]
  end
end

class ActiveRecord
  class Base
    def self.connection_pool
      Connection.new
    end
  end

  class Connection
    @@okay = true

    def with_connection(*args)
      raise "uh oh" unless @@okay
      yield self
    end

    def select_value(*_)
      Time.now
    end
  end

end

class Sidekiq
  def self.redis
    yield Redis.new
  end

  class ProcessSet
    @@size = 1

    def size
      @@size
    end
  end

  class Redis
    @@status = true

    def set(*_)
      raise "oops" unless @@status
    end

    def get(*_)
      raise "oops" unless @@status
    end
  end
end

class Rails
  def self.cache
    return Cache.new
  end

  class Cache
    @@status = true

    def write(*_)
      @@status
    end

    def read(*_)
      @@status
    end
  end
end


class GovDelivery::HealthCheckTest < Minitest::Test
  def setup
    @maintfile = '/tmp/maintenance.lock'
    @app = GovDelivery::HealthCheck::Web.new(
      happy_text: "just a test",
      maintfile:  @maintfile
    )
    @app.checks << CustomCheck
    @browser = Rack::Test::Session.new(Rack::MockSession.new(@app))

    Rails::Cache.class_variable_set('@@status', true)
    Sidekiq::Redis.class_variable_set('@@status', true)
    ActiveRecord::Connection.class_variable_set('@@okay', true)
    Sidekiq::ProcessSet.class_variable_set('@@size', 1)
  end

  def teardown
    FileUtils.rm_rf(@maintfile)
  end

  def test_custom_logger
    logger = Object.new
    app = GovDelivery::HealthCheck::Web.new
    app.logger = logger
    assert_equal logger, app.logger
  end

  def test_happy_path
    @browser.get "/"
    assert_equal 200, @browser.last_response.status
    assert_equal "just a test", @browser.last_response.body
  end

  def test_maintenance
    FileUtils.touch(@maintfile)
    @browser.get "/"
    assert_equal 503, @browser.last_response.status
    assert_equal "down for maintenance", @browser.last_response.body
  end

  def test_rails_cache_fail
    Rails::Cache.class_variable_set('@@status', false)
    @browser.get "/"
    assert_equal 202, @browser.last_response.status
    assert_equal "just a test - GovDelivery::HealthCheck::Checks::RailsCache: cache write failed", @browser.last_response.body
  end

  def test_sidekiq_redis_fail
    Sidekiq::Redis.class_variable_set('@@status', false)
    @browser.get "/"
    assert_equal 500, @browser.last_response.status
    assert_equal "oops", @browser.last_response.body
  end

  def test_sidekiq_down
    Sidekiq::ProcessSet.class_variable_set('@@size', 0)
    @browser.get "/"
    assert_equal 202, @browser.last_response.status
    assert_equal "just a test - GovDelivery::HealthCheck::Checks::Sidekiq: no active sidekiq processes", @browser.last_response.body
  end

  def test_sidekiq_down_and_database_error
    Sidekiq::ProcessSet.class_variable_set('@@size', 0)
    ActiveRecord::Connection.class_variable_set('@@okay', false)
    @browser.get "/"
    assert_equal 500, @browser.last_response.status
    assert_equal "GovDelivery::HealthCheck::Checks::Sidekiq: no active sidekiq processes, uh oh", @browser.last_response.body
  end

  def test_custom_check_warn
    @browser.get "/", warn: true
    assert_equal 202, @browser.last_response.status
    assert_equal "just a test - CustomCheck: warn!", @browser.last_response.body
  end

  def test_custom_check_fatal
    @browser.get "/", fatal: true
    assert_equal 518, @browser.last_response.status
    assert_equal "CustomCheck: fatal!", @browser.last_response.body
  end
end
