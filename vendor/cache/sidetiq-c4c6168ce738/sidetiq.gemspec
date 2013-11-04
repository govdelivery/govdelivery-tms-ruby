# -*- encoding: utf-8 -*-
# stub: sidetiq 0.4.3 ruby lib

Gem::Specification.new do |s|
  s.name = "sidetiq"
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Svensson"]
  s.date = "2013-11-04"
  s.description = "Recurring jobs for Sidekiq"
  s.email = ["tob@tobiassvensson.co.uk"]
  s.files = [".gitignore", ".travis.yml", "CHANGELOG.md", "Gemfile", "LICENSE", "README.md", "Rakefile", "examples/Procfile", "examples/config.ru", "examples/server.rb", "examples/workers/failing.rb", "examples/workers/simple.rb", "lib/sidetiq.rb", "lib/sidetiq/actor.rb", "lib/sidetiq/actor/clock.rb", "lib/sidetiq/actor/handler.rb", "lib/sidetiq/api.rb", "lib/sidetiq/clock.rb", "lib/sidetiq/config.rb", "lib/sidetiq/handler.rb", "lib/sidetiq/lock/meta_data.rb", "lib/sidetiq/lock/redis.rb", "lib/sidetiq/lock/watcher.rb", "lib/sidetiq/logging.rb", "lib/sidetiq/middleware/history.rb", "lib/sidetiq/schedulable.rb", "lib/sidetiq/schedule.rb", "lib/sidetiq/subclass_tracking.rb", "lib/sidetiq/supervisor.rb", "lib/sidetiq/version.rb", "lib/sidetiq/views/_home_nav.erb", "lib/sidetiq/views/_worker_nav.erb", "lib/sidetiq/views/assets/styles.css", "lib/sidetiq/views/history.erb", "lib/sidetiq/views/locks.erb", "lib/sidetiq/views/schedule.erb", "lib/sidetiq/views/sidetiq.erb", "lib/sidetiq/web.rb", "sidetiq.gemspec", "tasks/bundler.task", "tasks/minitest.task", "test/fixtures/backfill_worker.rb", "test/fixtures/last_and_scheduled_ticks_worker.rb", "test/fixtures/last_tick_worker.rb", "test/fixtures/optional_arguments_worker.rb", "test/fixtures/scheduled_worker.rb", "test/fixtures/simple_worker.rb", "test/fixtures/splat_args_worker.rb", "test/helper.rb", "test/test_clock.rb", "test/test_config.rb", "test/test_history.rb", "test/test_lock_meta_data.rb", "test/test_lock_redis.rb", "test/test_schedule.rb", "test/test_sidetiq.rb", "test/test_subclass_tracking.rb", "test/test_version.rb", "test/test_watcher.rb", "test/test_web.rb", "test/test_worker.rb"]
  s.homepage = "http://github.com/tobiassvn/sidetiq"
  s.licenses = ["3-clause BSD"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.9"
  s.summary = "Recurring jobs for Sidekiq"
  s.test_files = ["test/fixtures/backfill_worker.rb", "test/fixtures/last_and_scheduled_ticks_worker.rb", "test/fixtures/last_tick_worker.rb", "test/fixtures/optional_arguments_worker.rb", "test/fixtures/scheduled_worker.rb", "test/fixtures/simple_worker.rb", "test/fixtures/splat_args_worker.rb", "test/helper.rb", "test/test_clock.rb", "test/test_config.rb", "test/test_history.rb", "test/test_lock_meta_data.rb", "test/test_lock_redis.rb", "test/test_schedule.rb", "test/test_sidetiq.rb", "test/test_subclass_tracking.rb", "test/test_version.rb", "test/test_watcher.rb", "test/test_web.rb", "test/test_worker.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sidekiq>, ["~> 2.16.0"])
      s.add_runtime_dependency(%q<celluloid>, [">= 0.14.1"])
      s.add_runtime_dependency(%q<ice_cube>, ["~> 0.11.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 5.0.7"])
    else
      s.add_dependency(%q<sidekiq>, ["~> 2.16.0"])
      s.add_dependency(%q<celluloid>, [">= 0.14.1"])
      s.add_dependency(%q<ice_cube>, ["~> 0.11.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 5.0.7"])
    end
  else
    s.add_dependency(%q<sidekiq>, ["~> 2.16.0"])
    s.add_dependency(%q<celluloid>, [">= 0.14.1"])
    s.add_dependency(%q<ice_cube>, ["~> 0.11.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 5.0.7"])
  end
end
