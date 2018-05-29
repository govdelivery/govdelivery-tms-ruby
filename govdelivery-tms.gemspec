# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'govdelivery/tms/version'

Gem::Specification.new do |s|
  s.name        = 'govdelivery-tms'
  s.version     = GovDelivery::TMS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['GovDelivery']
  s.email       = ['support@govdelivery.com']
  s.homepage    = 'http://govdelivery.com'
  s.summary     = 'A ruby client to interact with the GovDelivery TMS REST API.'
  s.description = "A reference implementation, written in Ruby,
                     to interact with GovDelivery's TMS API. The client is
                     compatible with Ruby 1.9 and 2.0. "

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'faraday_middleware'
  s.add_runtime_dependency 'mime-types'

  s.files       = %w(
    Gemfile
    README.md
    Rakefile
    govdelivery-tms.gemspec
    .version
  ) + Dir['lib/**/*']

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
end
