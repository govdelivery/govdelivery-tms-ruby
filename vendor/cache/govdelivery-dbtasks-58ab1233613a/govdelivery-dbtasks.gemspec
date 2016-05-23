# -*- encoding: utf-8 -*-
# stub: govdelivery-dbtasks 0.4.4 ruby lib tasks

Gem::Specification.new do |s|
  s.name = "govdelivery-dbtasks"
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "http://prod-rubygems1-ep.tops.gdi" } if s.respond_to? :metadata=
  s.authors = ["Benjamin Ortega"]
  s.bindir = "exe"
  s.date = "2016-05-23"
  s.description = "Internal gem with oracle rake tasks for GovD projects."
  s.email = ["ben.ortega@gmail.com"]
  s.files = [".gitignore", ".rspec", ".travis.yml", "Appraisals", "Gemfile", "README.md", "Rakefile", "bin/console", "bin/setup", "gemfiles/rails32.gemfile", "gemfiles/rails32.gemfile.lock", "gemfiles/rails41.gemfile", "gemfiles/rails41.gemfile.lock", "gemfiles/rails42.gemfile", "gemfiles/rails42.gemfile.lock", "govdelivery-dbtasks.gemspec", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced/current_schema_statements.rb", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced/current_schema_structure_dump.rb", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced/database_tasks.rb", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced_adapter.rb", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced_connection.rb", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced_current_schema_adapter.rb", "lib/govdelivery/active_record/connection_adapters/oracle_enhanced_current_schema_oci_connection.rb", "lib/govdelivery/active_record/migration.rb", "lib/govdelivery/active_record/safe_migration.rb", "lib/govdelivery/active_record/schema_migration.rb", "lib/govdelivery/active_record/tasks/database_tasks.rb", "lib/govdelivery/dbtasks.rb", "lib/govdelivery/dbtasks/databases.rake", "lib/govdelivery/dbtasks/railtie.rb", "lib/govdelivery/dbtasks/version.rb"]
  s.homepage = "http://www.govdelivery.com"
  s.require_paths = ["lib", "tasks"]
  s.rubygems_version = "2.1.9"
  s.summary = "Internal gem with oracle rake tasks for GovD projects."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.8"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 4.0"])
      s.add_runtime_dependency(%q<activerecord>, ["~> 4.0"])
      s.add_runtime_dependency(%q<activerecord-oracle_enhanced-adapter>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-plsql>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.8"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<activesupport>, ["~> 4.0"])
      s.add_dependency(%q<activerecord>, ["~> 4.0"])
      s.add_dependency(%q<activerecord-oracle_enhanced-adapter>, [">= 0"])
      s.add_dependency(%q<ruby-plsql>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.8"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<activesupport>, ["~> 4.0"])
    s.add_dependency(%q<activerecord>, ["~> 4.0"])
    s.add_dependency(%q<activerecord-oracle_enhanced-adapter>, [">= 0"])
    s.add_dependency(%q<ruby-plsql>, [">= 0"])
  end
end
