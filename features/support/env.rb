require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'configatron'
require 'multi_xml'
require 'govdelivery-tms-internal'

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
    :prod
  ]
  env = ENV.key?('XACT_ENV') ? ENV['XACT_ENV'].to_sym : :development
  raise "Unsupported XACT Environment: #{env}" unless environments.include?(env)
  env
end

def xact_url
  urls = {
    development: 'http://localhost:3000',
    qc: 'https://qc-tms.govdelivery.com',
    integration: 'https://int-tms.govdelivery.com',
    stage: 'https://stage-tms.govdelivery.com',
    prod: 'https://tms.govdelivery.com'
  }

  url = urls[environment]
  raise "No XACT URL defined for environment #{environment}" unless url
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

def message_types
  [
    :email,
    :sms,
    :voice
  ]
end

def event_types
  [
    :sending,
    :sent,
    :failed,
    :blacklisted,
    :inconclusive,
    :canceled
  ]
end

def magic_addresses(message_type)
  case message_type
  when :email
    magic_emails
  when :sms
    magic_phone_numbers
  when :voice
    magic_phone_numbers
  end
end

def magic_emails
  {
    sending: 'sending@sink.govdelivery.com',
    sent: 'sent@sink.govdelivery.com',
    failed: 'failed@sink.govdelivery.com',
    blacklisted: 'blacklisted@sink.govdelivery.com',
    inconclusive: 'inconclusive@sink.govdelivery.com',
    canceled: 'canceled@sink.govdelivery.com'
  }
end

def magic_phone_numbers
  {
    #:new => "15005550000",
    sending: '15005550001',
    inconclusive: '15005550002',
    canceled: '15005550003',
    failed: '15005550004',
    blacklisted: '15005550005',
    sent: '15005550006'
  }
end

def status_for_address(magic_addresses, address)
  matches = magic_addresses.select { |_status, magic_address| magic_address == address}
  status = matches ? matches.first.first : nil
  status
end

def callbacks_api_root
  'http://xact-webhook-callbacks.herokuapp.com/api/v3/'
end

def callbacks_api_sms_root
  'http://xact-webhook-callbacks.herokuapp.com/api/v3/sms/'
end

def twilio_xact_test_number_2
  '+17014842689'
end

def tms_client(conf)
  GovDelivery::TMS::Client.new(conf.xact.user.token, api_root: conf.xact.url)
end

#
# Returns true if testing development without a token for a live account
#
def dev_not_live?
  return false unless environment == :development

  !(configatron.xact.key?('user') && configatron.xact.user.key?('token'))
end

def dcm_base64_url
  if ENV['XACT_ENV'] == 'qc'
    'https://qc-api.govdelivery.com/api/account/CUKEAUTO_QC/subscribers/'
  elsif ENV['XACT_ENV'] == 'integration'
    'https://int-api.govdelivery.com/api/account/CUKEAUTO_INT/subscribers/'
  elsif ENV['XACT_ENV'] == 'stage'
    'https://stage-api.govdelivery.com/api/account/CUKEAUTO_STAGE/subscribers/'
  elsif ENV['XACT_ENV'] == 'prod'
    'https://api.govdelivery.com/api/account/CUKEAUTO_PROD/subscribers/'
  end
end

def user
  if ENV['XACT_ENV'] == 'qc'
    @request = HTTPI::Request.new
    @request.headers['Content-Type'] = 'application/xml'
    @request.auth.basic('autocukeqc_sa@evotest.govdelivery.com', 'govdel01!')
  elsif ENV['XACT_ENV'] == 'integration'
    @request = HTTPI::Request.new
    @request.headers['Content-Type'] = 'application/xml'
    @request.auth.basic('autocukeint_sa@evotest.govdelivery.com', 'govdel01!')
  elsif ENV['XACT_ENV'] == 'stage'
    @request = HTTPI::Request.new
    @request.headers['Content-Type'] = 'application/xml'
    @request.auth.basic('autocukestage_sa@evotest.govdelivery.com', 'govdel01!')
  elsif ENV['XACT_ENV'] == 'prod'
    @request = HTTPI::Request.new
    @request.headers['Content-Type'] = 'application/xml'
    @request.auth.basic('autocukeprod_sa@evotest.govdelivery.com', 'govdel01!')
  end
end

def sample_subscriber_number
  '+16122236629'
end
