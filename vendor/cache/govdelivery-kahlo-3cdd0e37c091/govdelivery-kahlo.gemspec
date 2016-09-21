# -*- encoding: utf-8 -*-
# stub: govdelivery-kahlo 0.1.0 java lib

Gem::Specification.new do |s|
  s.name = "govdelivery-kahlo"
  s.version = "0.1.0"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "http://prod-rubygems1-ep.tops.gdi" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Benjamin Ortega"]
  s.bindir = "exe"
  s.date = "2016-09-19"
  s.description = "send messages and find out what happened with them"
  s.email = ["ben.ortega@gmail.com"]
  s.files = ["README.md", "lib/govdelivery-kahlo.rb", "lib/govdelivery/kahlo.rb", "lib/govdelivery/kahlo/client.rb", "lib/govdelivery/kahlo/global_phone.json", "lib/govdelivery/kahlo/invalid_message.rb", "lib/govdelivery/kahlo/validation_helper.rb", "lib/govdelivery/kahlo/version.rb"]
  s.homepage = "http://dev-scm.office.gdi"
  s.rubygems_version = "2.4.8"
  s.summary = "Kahlo Ruby client"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.12"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>, ["~> 5.0"])
      s.add_runtime_dependency(%q<govdelivery-synapse>, [">= 0.8.0"])
      s.add_runtime_dependency(%q<global_phone>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.12"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<minitest>, ["~> 5.0"])
      s.add_dependency(%q<govdelivery-synapse>, [">= 0.8.0"])
      s.add_dependency(%q<global_phone>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.12"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<minitest>, ["~> 5.0"])
    s.add_dependency(%q<govdelivery-synapse>, [">= 0.8.0"])
    s.add_dependency(%q<global_phone>, [">= 0"])
  end
end
