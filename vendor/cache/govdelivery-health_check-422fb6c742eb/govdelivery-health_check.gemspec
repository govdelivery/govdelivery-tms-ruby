# -*- encoding: utf-8 -*-
# stub: govdelivery-health_check 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "govdelivery-health_check"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "http://prod-rubygems1-ep.tops.gdi" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Benjamin Ortega"]
  s.bindir = "exe"
  s.date = "2016-09-23"
  s.description = "health check middleware and some other stuff"
  s.email = ["ben.ortega@gmail.com"]
  s.files = [".gitignore", ".gitlab-ci.yml", "CODE_OF_CONDUCT.md", "Gemfile", "README.md", "Rakefile", "bin/console", "bin/setup", "govdelivery-health_check.gemspec", "lib/govdelivery/health_check.rb", "lib/govdelivery/health_check/oracle.rb", "lib/govdelivery/health_check/rails_cache.rb", "lib/govdelivery/health_check/sidekiq.rb", "lib/govdelivery/health_check/version.rb", "lib/govdelivery/health_check/warning.rb", "lib/govdelivery/health_check/web.rb"]
  s.homepage = "http://geeks.gd"
  s.rubygems_version = "2.4.8"
  s.summary = "health check tools"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.12"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>, ["~> 5.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.12"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<minitest>, ["~> 5.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.12"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<minitest>, ["~> 5.0"])
  end
end
