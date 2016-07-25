require 'test_helper'
require 'minitest/pride'
require 'fileutils'

class ActiveRecord
  class Base
    def self.with_connection
      yield Connection.new
    end
  end

  class Connection
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
    @stopfile  = "/tmp/stopfile.lock"
    @maintfile = '/tmp/maintenance.lock'
    @app       = GovDelivery::HealthCheck::Web.new(
      happy_text: "just a test",
      stopfile:   @stopfile,
      maintfile:  @maintfile)
    @env       = {}
    Rails::Cache.class_variable_set('@@status', true)
    Sidekiq::Redis.class_variable_set('@@status', true)
    Sidekiq::ProcessSet.class_variable_set('@@size', 1)
  end

  def teardown
    FileUtils.rm_rf(@stopfile)
    FileUtils.rm_rf(@maintfile)
  end

  def test_happy_path
    assert_equal [200, {"Content-Type" => 'text/plain'}, ["just a test"]], @app.call(@env)
  end

  def test_stopping
    FileUtils.touch(@stopfile)
    assert_equal [307, {"Content-Type" => 'text/plain'}, ["shutting down"]], @app.call(@env)
  end

  def test_maintenance
    FileUtils.touch(@maintfile)
    assert_equal [503, {"Content-Type" => 'text/plain'}, ["down for maintenance"]], @app.call(@env)
  end

  def test_rails_cache_fail
    Rails::Cache.class_variable_set('@@status', false)
    assert_equal [429, {"Content-Type" => 'text/plain'}, ["GovDelivery::HealthCheck::RailsCache: cache write failed"]], @app.call(@env)
  end

  def test_sidekiq_redis_fail
    Sidekiq::Redis.class_variable_set('@@status', false)
    assert_equal [500, {"Content-Type" => 'text/plain'}, ["oops"]], @app.call(@env)
  end

  def test_sidekiq_down
    Sidekiq::ProcessSet.class_variable_set('@@size', 0)
    assert_equal [429, {"Content-Type" => 'text/plain'}, ["GovDelivery::HealthCheck::Sidekiq: no active sidekiq processes"]], @app.call(@env)
  end

end
