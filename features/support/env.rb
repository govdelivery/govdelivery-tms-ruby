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
    :int => "https://int-tms.govdelivery.com",
    :stage => "https://stage-tms.govdelivery.com",
    :prod => "https://tms.govdelivery.com"
  }

  url = urls[environment]
  raise "No XACT URL defined for environment #{environment}" if !url
  url
end

# Returns the appropriate XACT token based on the type of account that should be used, and the environment being tested.
#
# If the XACT_TOKEN environment variable is set, that will be returned regardless of the account type or the test environment.
#
# +account_type+:: :live or :loopback - Determines whether to use an account that sends messages or an account that does not.
def xact_token(account_type = :live)
  return ENV['XACT_TOKEN'] if ENV['XACT_TOKEN']

  case account_type
    when :live
      tokens = {
        :dev => ENV['XACT_LIVE_TOKEN'],
        :qc => 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp',
        :int => 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL',
        :stage => 'd6pAps9Xw3gqf6yxreHbwonpmb9JywV3'
      }
    when :loopback
      tokens = {
        :dev => ENV['XACT_LOOPBACK_TOKEN'],
        :qc => 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL'
      }
  end

  token = tokens[environment]
  raise "No XACT Token defined for environment #{environment} and account type #{account_type}" if !token
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
    :sending,
    :sent,
    :failed,
    :blacklisted,
    :inconclusive,
    :canceled
  ]
end

def magic_emails
  magic_emails = {
    :sending => "sending@sink.govdelivery.com",
    :sent => "sent@sink.govdelivery.com",
    :failed => "failed@sink.govdelivery.com",
    :blacklisted => "blacklisted@sink.govdelivery.com",
    :inconclusive => "inconclusive@sink.govdelivery.com",
    :canceled => "canceled@sink.govdelivery.com"
  }
end

def magic_phone_numbers
  magic_phone_numbers = {
    #:new => "15005550000",
    :sending => "15005550001",
    :inconclusive => "15005550002",
    :canceled => "15005550003",
    :failed => "15005550004",
    :blacklisted => "15005550005",
    :sent => "15005550006"
  }
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

def status_for_address(magic_addresses, address)
  matches = magic_addresses.select {|status, magic_address| magic_address == address}
  status = matches ? matches.first.first : nil
  return status
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

def tms_client(account_type = :live)
  client = TMS::Client.new(xact_token(account_type), :api_root => xact_url)
end
