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

def ensure_deleted(record)
  begin
    if record.try(:get)
      record.delete!
    end
  rescue GovDelivery::TMS::Request::Error, GovDelivery::TMS::Errors::InvalidGet
# ignored
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

def env_prefix
  {
    qc:          'qc-',
    integration: 'int-',
    stage:       'stage-',
    prod:        '',
  }[environment]
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

configatron.configure_from_hash(YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'common.yaml')))

if (File.exists?(env_config = File.join(File.dirname(__FILE__), 'config', "#{environment}.yaml")))
  configatron.configure_from_hash(YAML.load_file(env_config))
end

configatron.xact.url = xact_url
configatron.kahlo.url = "https://#{env_prefix}sms.govdelivery.com"

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

configatron.sms_vendors.live.phone.number = twilio_live_numbers[environment]
configatron.sms_vendors.live.phone.sid    = twilio_live_phone_sids[environment]

configatron.voice_vendors.live.phone.number = twilio_live_numbers[environment]
configatron.voice_vendors.live.phone.sid    = twilio_live_phone_sids[environment]


def message_body_identifier
  [Time.new, '::', rand(100_000)].map(&:to_s).join
end

#
# Returns true if testing development without a token for a live account
#
def dev_not_live?
  return false unless environment == :development

  !configatron.xact.key?('token')
end

