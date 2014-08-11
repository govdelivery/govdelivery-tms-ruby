# -*- encoding: utf-8 -*-
# stub: sidekiq-retries 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-retries"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Benjamin Ortega"]
  s.date = "2014-08-11"
  s.description = "Enhanced retry logic for Sidekiq workers"
  s.email = ["ben.ortega@gmail.com"]
  s.files = [".gitignore", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "lib/sidekiq/retries.rb", "lib/sidekiq/retries/errors.rb", "lib/sidekiq/retries/server/middleware.rb", "lib/sidekiq/retries/version.rb", "sidekiq-retries.gemspec", "spec/lib/sidekiq/retries/server/middleware_spec.rb", "spec/spec_helper.rb"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.9"
  s.summary = "Enhanced retry logic for Sidekiq workers"
  s.test_files = ["spec/lib/sidekiq/retries/server/middleware_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sidekiq>, ["~> 3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rspec-mocks>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, ["~> 3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rspec-sidekiq>, [">= 0"])
    else
      s.add_dependency(%q<sidekiq>, ["~> 3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rspec-mocks>, [">= 0"])
      s.add_dependency(%q<activesupport>, ["~> 3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rspec-sidekiq>, [">= 0"])
    end
  else
    s.add_dependency(%q<sidekiq>, ["~> 3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rspec-mocks>, [">= 0"])
    s.add_dependency(%q<activesupport>, ["~> 3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rspec-sidekiq>, [">= 0"])
  end
end
