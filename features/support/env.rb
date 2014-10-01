require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'tms_client'


Capybara.default_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
options = {
    :js_errors => false,
    :timeout => 30,
    :debug => false,
    :phantomjs_options => ['--load-images=no', '--disk-cache=false'],
    :inspector => true,
}
Capybara::Poltergeist::Driver.new(app, options)
end

def xact_url
  urls = {
    :dev => "http://localhost:3000",
    :qc => "https://qc-tms.govdelivery.com",
    :stage => "https://stage-tms.govdelivery.com",
    :int => "https://int-tms.govdelivery.com",
    :prod => "https://tms.govdelivery.com"
  }

  url = urls[environment]
  raise "No XACT URL defined for environment #{environment}" if !url
  url
end

def xact_token
  tokens = {
    :dev => ENV['XACT_TOKEN'],
    :qc => 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp'
  }

  token = tokens[environment]
  raise "No XACT Token defined for environment #{environment}" if !token
  token
end

def message_types
  message_types = [
    :email,
    :sms,
    :voice
  ]
end

def event_types
  event_types = [
    "sending",
    "sent",
    "failed",
    "blacklisted",
    "inconclusive",
    "canceled"
  ]
end

def magic_emails
  magic_emails = [
    "sending@sink.govdelivery.com",
    "sent@sink.govdelivery.com",
    "failing@sink.govdelivery.com",
    "blacklisted@sink.govdelivery.com",
    "inconclusive@sink.govdelivery.com",
    "canceled@sink.govdelivery.com"
  ]
end

def magic_phone_numbers
  magic_phone_numbers = [
#    "15005550000",
    "15005550001",
    "15005550002",
    "15005550003",
    "15005550004",
    "15005550005",
 #   "15005550006"
  ]
end

def callbacks_api_root
  'http://xact-webhook-callbacks.herokuapp.com/api/v2/'
end

def environment
  environments = [
    :dev,
    :qc,
    :stage,
    :int,
    :prod
  ]
  env = ENV.has_key?('XACT_ENV') ? ENV['XACT_ENV'].to_sym : :dev
  raise "Unsupported XACT Environment: #{env}" if !environments.include?(env)
  env
end

def tms_client
  client = TMS::Client.new(xact_token, :api_root => xact_url)
end