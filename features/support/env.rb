require 'awesome_print'
require 'base64'
require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'configatron'
require 'colored'
require 'date'
require 'faraday'
require 'govdelivery-proctor'
require 'govdelivery-tms-internal'
require 'json'
require 'mail'
require 'mechanize'
require 'multi_xml'
require 'net/imap'
require 'net/http'
require 'pp'
require 'pry'
require 'rubygems'
require 'uri'
require 'twilio-ruby'


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


Capybara.default_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  options = {
    js_errors: false,
    timeout: 30,
    debug: false,
    phantomjs_options: ['--load-images=no', '--disk-cache=false'],
    inspector: true
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

def environment
  environments = [
    :development,
    :qc,
    :integration,
    :stage,
    :prod,
    :mbloxqc,
    :mbloxintegration,
    :mbloxstage,
    :mbloxproduction
  ]
  env = ENV.key?('XACT_ENV') ? ENV['XACT_ENV'].to_sym : :development
  raise "Unsupported XACT Environment: #{env}" unless environments.include?(env)
  env
end

def log
  GovDelivery::Proctor.log
end

def faraday(url)
  Faraday.new(url: url) do |faraday|
    faraday.request :url_encoded
    faraday.response :logger, log
    faraday.adapter Faraday.default_adapter
  end
end

def site
  sites = [
    :dc3,
  ]
  site = ENV.has_key?('SITE') ? ENV['SITE'].to_sym : nil
  raise "Unsupported Site: #{site}" if (ENV['SITE'] && !sites.include?(site))
  site
end

def xact_url
  urls = {
    :development => "http://localhost:3000",
    :qc => "https://qc-tms.govdelivery.com",
    :qc_dc3 => "https://qc-tms-dc3.govdelivery.com",
    :integration => "https://int-tms.govdelivery.com",
    :stage => "https://stage-tms.govdelivery.com",
    :prod => "https://tms.govdelivery.com",
    :mbloxqc => "https://qc-tms.govdelivery.com",
    :mbloxintegration => "https://int-tms.govdelivery.com",
    :mbloxstage => "https://stage-tms.govdelivery.com",
    :mbloxproduction => "https://tms.govdelivery.com"
  }

  if(lsite = site)
    lsite = ('_' + site.to_s).to_sym
  end

  url = urls[(environment.to_s + lsite.to_s).to_sym]
  log.info "url: #{url}"
  raise "No XACT URL defined for environment #{environment}" if !url
  url
end

# Set general configuration options
twilio_test_credentials = {
  sid: 'ACc66477e37af9ebee0f12b349c7b75117',
  token: '5b1c96ca034d474c6d4b68f8d05c99f5'
}

twilio_live_credentials = {
  sid: 'AC189315456a80a4d1d4f82f4a732ad77e',
  token: '88e3775ad71e487c7c90b848a55a5c88'
}

twilio_live_numbers = {
  development: '+16514336311',
  qc: '+16519684981',
  integration: '+16519641178',
  stage: '+16124247727'
}

twilio_live_phone_sids = {
  development: 'PN06416578aa730a3e8f0fd3865ce9c458',
  qc: 'PN732e0d02edf9e1fdd61a3606ac030e34',
  integration: 'PN462de8d1be0c1c23670f75ee73d70715',
  stage: 'PNe896243b192ff04674538f3aa11ea839'
}

configatron.xact.url                                  = xact_url
configatron.test_support.mblox.phone.number           = '+16122546317'
configatron.test_support.twilio.phone.number          = '+15183004174'
configatron.test_support.twilio.phone.sid             = 'PN53d0531f78bf8061549b953c6619b753'
configatron.test_support.twilio.account.sid           = 'AC189315456a80a4d1d4f82f4a732ad77e'
configatron.test_support.twilio.account.token         = '88e3775ad71e487c7c90b848a55a5c88'
configatron.test_support.twilio.account.twilio_test   = false

configatron.sms_vendors.loopback.phone.number          = '+15552287439'   # 1-555-BBushey --or-- 1-555-CatShew --or-- 1-555-BatsHey
configatron.sms_vendors.loopback.vendor.username       = 'shared_loopback_sms_username'
configatron.sms_vendors.loopback.vendor.password       = 'dont care'
configatron.sms_vendors.loopback.vendor.shared         = true
configatron.sms_vendors.loopback.vendor.twilio_test    = false

configatron.voice_vendors.loopback.phone.number        = '+15552287439'   # 1-555-BBushey --or-- 1-555-CatShew --or-- 1-555-BatsHey
configatron.voice_vendors.loopback.vendor.password     = 'dont care'
configatron.voice_vendors.loopback.vendor.twilio_test  = false

configatron.sms_vendors.twilio_valid_test.phone.number       = '+15005550006'
configatron.sms_vendors.twilio_valid_test.vendor.username    = twilio_test_credentials[:sid]
configatron.sms_vendors.twilio_valid_test.vendor.password    = twilio_test_credentials[:token]
configatron.sms_vendors.twilio_valid_test.vendor.shared      = true
configatron.sms_vendors.twilio_valid_test.vendor.twilio_test = true

configatron.sms_vendors.twilio_invalid_test.phone.number       = '+15005550001'
configatron.sms_vendors.twilio_invalid_test.vendor.username    = twilio_test_credentials[:sid]
configatron.sms_vendors.twilio_invalid_test.vendor.password    = twilio_test_credentials[:token]
configatron.sms_vendors.twilio_invalid_test.vendor.shared      = true
configatron.sms_vendors.twilio_invalid_test.vendor.twilio_test = true

configatron.sms_vendors.live.phone.number                       = twilio_live_numbers[environment]
configatron.sms_vendors.live.phone.sid                          = twilio_live_phone_sids[environment]
configatron.sms_vendors.live.vendor.username                    = twilio_live_credentials[:sid]
configatron.sms_vendors.live.vendor.password                    = twilio_live_credentials[:token]
configatron.sms_vendors.live.vendor.shared                      = true
configatron.sms_vendors.live.vendor.twilio_test                 = false

configatron.voice_vendors.live.phone.number                     = twilio_live_numbers[environment]
configatron.voice_vendors.live.phone.sid                        = twilio_live_phone_sids[environment]
configatron.voice_vendors.live.vendor.username                  = twilio_live_credentials[:sid]
configatron.voice_vendors.live.vendor.password                  = twilio_live_credentials[:token]
configatron.voice_vendors.live.vendor.twilio_test               = false

def twilio_xact_test_number_2
  '+17014842689'
end

def message_body_identifier
  [Time.new, '::', rand(100_000)].map(&:to_s).join
end

#
# Returns true if testing development without a token for a live account
#
def dev_not_live?
  return false unless environment == :development

  !(configatron.xact.key?('user') && configatron.xact.user.key?('token'))
end

def sample_subscriber_number
  '+16122236629'
end
