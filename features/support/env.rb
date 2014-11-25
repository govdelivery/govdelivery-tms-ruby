require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'configatron'
require 'tms_client'
require 'multi_xml'


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

def environment
  environments = [
    :development,
    :qc,
    :integration,
    :stage,
    :prod
  ]
  env = ENV.has_key?('XACT_ENV') ? ENV['XACT_ENV'].to_sym : :development
  raise "Unsupported XACT Environment: #{env}" if !environments.include?(env)
  env
end

def xact_url
  urls = {
    :development => "http://localhost:3000",
    :qc => "https://qc-tms.govdelivery.com",
    :integration => "https://int-tms.govdelivery.com",
    :stage => "https://stage-tms.govdelivery.com",
    :prod => "https://tms.govdelivery.com"
  }

  url = urls[environment]
  raise "No XACT URL defined for environment #{environment}" if !url
  url
end

# Set general configuration options
configatron.xact.url                                  = xact_url

configatron.test_support.twilio.phone.number          = '+15183004174'
configatron.test_support.twilio.phone.sid             = 'PN53d0531f78bf8061549b953c6619b753'
configatron.test_support.twilio.account.sid           = 'AC189315456a80a4d1d4f82f4a732ad77e'
configatron.test_support.twilio.account.token         = '88e3775ad71e487c7c90b848a55a5c88'
configatron.test_support.twilio.account.twilio_test   = false

configatron.sms_vendor.loopback.phone.number          = '+15552287439',   # 1-555-BBushey --or-- 1-555-CatShew --or-- 1-555-BatsHey
configatron.sms_vendor.loopback.vendor.username       = 'shared_loopback_sms_username'
configatron.sms_vendor.loopback.vendor.password       = 'dont care'
configatron.sms_vendor.loopback.vendor.shared         = true
configatron.sms_vendor.loopback.vendor.twilio_test    = false

configatron.voice_vendor.loopback.phone.number        = '+15552287439',   # 1-555-BBushey --or-- 1-555-CatShew --or-- 1-555-BatsHey configatron.sms_vendor.loopback.vendor.username       = 'shared_loopback_sms_username'
configatron.voice_vendor.loopback.vendor.password     = 'dont care'
configatron.voice_vendor.loopback.vendor.twilio_test  = false

configatron.sms_vendor.twilio_test.phone.number       = '+15005550006'
configatron.sms_vendor.twilio_test.vendor.username    = 'ACc66477e37af9ebee0f12b349c7b75117'
configatron.sms_vendor.twilio_test.vendor.password    = '5b1c96ca034d474c6d4b68f8d05c99f5'
configatron.sms_vendor.twilio_test.vendor.shared      = false
configatron.sms_vendor.twilio_test.vendor.twilio_test = true

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
        :development => ENV['XACT_LIVE_TOKEN'],
        :qc => 'gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp',
        :integration => 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL',
        :stage => 'd6pAps9Xw3gqf6yxreHbwonpmb9JywV3'
      }
    when :twilio_test
      tokens = {
        :development => ENV['XACT_TWILIO_TEST_TOKEN'],
        :qc => 'Br7wEWVPPpGFbwdJMZSDezKEJaYXCpgT'
      }
    when :loopback
      tokens = {
        :development => ENV['XACT_LOOPBACK_TOKEN'],
        :qc => 'sXNsShoQRX1X5qa5ZuegCzL7hUpebSdL',
        :integration => '7SxUtWmkq5Lsjnw2s5rxJULqrHs37AbE',
        :stage => 'CtyXxoinsNHujmfFd2qhKRJvDBMNqmPm'
      }
    when :bart
      tokens = {
        :development => ENV['XACT_BART_TOKEN'],
        :qc => xact_token(:loopback),
        :integration => xact_token(:loopback),
        :stage => xact_token(:loopback)
      }
  end

  token = tokens[environment]
  raise "No XACT Token defined for environment #{environment} and account type #{account_type}" if !token
  token
end

# Returns a hash with credentials and info for an Xact account, based on the environment being tested and the type of
# account requested.
#
# Returned hash includes:
# * token - Xact user token for API access
# * xact_url - URL to the Xact instance being tested
# * sms_phone - Phone number of the SMS Vendor of the account
# * sms_vendor_username - Twilio Account SID of the SMS Vendor, or mock SID for loopbacks account
# * sms_vendor_password - Twilio token of the SMS Vendor, or mock password for loopbacks account
# * sms_phone_sid - Twilio SID of of the SMS phone number
# * voice_phone | voice_vendor_username | voice_vendor_password | voice_phone_sid - The type of info as above, but for Voice Vendors
def xact_account(account_type = :live)
  account = {}
  account[:token] = xact_token(account_type)
  account[:xact_url] = xact_url
  case account_type
    when :live
      account[:sms_phone] = twilio_xact_test_number[:phone]
      account[:sms_vendor_username] = twilio_test_account_creds[:sid]
      account[:sms_vendor_password] = twilio_test_account_creds[:token]
      account[:sms_phone_sid] = twilio_xact_test_number[:sid]
      account[:voice_phone] = twilio_xact_test_number[:phone]
      account[:voice_vendor_username] = twilio_test_account_creds[:sid]
      account[:voice_vendor_password] = twilio_test_account_creds[:token]
      account[:voice_phone_sid] = twilio_xact_test_number[:sid]
    when :twilio_test
      account[:sms_phone] = '+15005550006'
      account[:sms_vendor_username] = twilio_test_test_account_creds[:sid]
      account[:sms_vendor_password] = twilio_test_test_account_creds[:token]
      account[:sms_phone_sid] = nil
      account[:voice_phone] = '+15005550006'
      account[:voice_vendor_username] = twilio_test_test_account_creds[:sid]
      account[:voice_vendor_password] = twilio_test_test_account_creds[:token]
      account[:voice_phone_sid] = nil
    when :loopback, :bart
      account[:sms_phone] = '+15559999999'
      account[:sms_vendor_username] = 'loopbacks_account_sms_username'
      account[:sms_vendor_password] = 'dont care'
      account[:sms_phone_sid] = nil
      account[:voice_phone] = '+15559999999'
      account[:voice_vendor_username] = 'loopbacks_account_voice_username'
      account[:voice_vendor_password] = 'dont care'
      account[:voice_phone_sid] = nil
  end

  return account
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
  'http://xact-webhook-callbacks.herokuapp.com/api/v3/'
end

def callbacks_api_sms_root
  'http://xact-webhook-callbacks.herokuapp.com/api/v3/sms/'
end

def twilio_test_account_creds
  {
    :sid => 'AC189315456a80a4d1d4f82f4a732ad77e',
    :token => '88e3775ad71e487c7c90b848a55a5c88'
  }
end

def twilio_test_test_account_creds
  {
    :sid => 'ACc66477e37af9ebee0f12b349c7b75117',
    :token => '5b1c96ca034d474c6d4b68f8d05c99f5'
  }
end

# Number to use to send SMSs to Xact
def twilio_xact_test_number
    if ENV['XACT_ENV'] == 'qc'
      {
      :phone => '+16519684981',
      :sid => 'AC189315456a80a4d1d4f82f4a732ad77e'
      }
    elsif ENV['XACT_ENV'] == 'integration'
      {
      :phone => '+16122550428',
      :sid => 'AC189315456a80a4d1d4f82f4a732ad77e'
      }
    elsif ENV['XACT_ENV'] == 'stage'
      {
      :phone => '+16124247727',
      :sid => 'AC189315456a80a4d1d4f82f4a732ad77e'
      }
    elsif ENV['XACT_ENV'] == 'prod'
      {
      :phone => '+16124247727',
      :sid => 'AC189315456a80a4d1d4f82f4a732ad77e'
      }
    end
end

def twilio_xact_test_number_2
  '+17014842689'
end

def environment
  environments = [
    :development,
    :qc,
    :integration,
    :stage,
    :prod
  ]
  env = ENV.has_key?('XACT_ENV') ? ENV['XACT_ENV'].to_sym : :development
  raise "Unsupported XACT Environment: #{env}" if !environments.include?(env)
  env
end

def tms_client(conf)
    client = TMS::Client.new(conf.xact.user.token, :api_root => conf.xact.url)
end

#
# Returns true if testing development without a token for a live account
#
def dev_not_live?
  return false unless environment == :development

  begin
    xact_token(:live)
    return false
  rescue

    return true
  end
end

def keyword_params
    if ENV['XACT_ENV'] == 'qc'
      "qc_subscribe"
    elsif ENV['XACT_ENV'] == 'integration'
      "int_subscribe"
    elsif ENV['XACT_ENV'] == 'stage'
      "stage_subscribe"
    elsif ENV['XACT_ENV'] == 'prod'
      "prod_subscribe"
    end
end

def subscribe_command
    if ENV['XACT_ENV'] == 'qc'
      'cuke qc_subscribe'
    elsif ENV['XACT_ENV'] == 'integration'
      'cukeint int_subscribe'
    elsif ENV['XACT_ENV'] == 'stage'
      'cuke stage_subscribe'
    elsif ENV['XACT_ENV'] == 'prod'
      'cuke prod_subscribe'
    end
end

def subscribe_command_2
    if ENV['XACT_ENV'] == 'qc'
      'cuke subscribe'
    elsif ENV['XACT_ENV'] == 'integration'
      'cukeint subscribe'
    elsif ENV['XACT_ENV'] == 'stage'
      'cuke subscribe'
    elsif ENV['XACT_ENV'] == 'prod'
      'cuke subscribe'
    end
end

def stop_command
  'stop'
end  

def start_command
  'start'
end  

#xact_2waysms - prints different param strings according to environment variable passed
def dcm_params
    if ENV['XACT_ENV'] == 'qc'
      {:dcm_account_code => "CUKEAUTO_QC", :dcm_topic_codes => ["CUKEAUTO_QC_SMS"]}
    elsif ENV['XACT_ENV'] == 'integration'
      {:dcm_account_code => "CUKEAUTO_INT", :dcm_topic_codes => ["CUKEAUTO_INT_SMS"]}
    elsif ENV['XACT_ENV'] == 'stage'
      {:dcm_account_code => "CUKEAUTO_STAGE", :dcm_topic_codes => ["CUKEAUTO_STAGE_SMS"]}
    elsif ENV['XACT_ENV'] == 'prod'
      {:dcm_account_code => "CUKEAUTO_PROD", :dcm_topic_codes => ["CUKEAUTO_PROD_SMS"]}
    end
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
      @request.headers["Content-Type"] = "application/xml"
      @request.auth.basic("autocukeqc_sa@evotest.govdelivery.com", "govdel01!")
    elsif ENV['XACT_ENV'] == 'integration'
      @request = HTTPI::Request.new
      @request.headers["Content-Type"] = "application/xml"
      @request.auth.basic("autocukeint_sa@evotest.govdelivery.com", "govdel01!")
    elsif ENV['XACT_ENV'] == 'stage'
      @request = HTTPI::Request.new
      @request.headers["Content-Type"] = "application/xml"
      @request.auth.basic("autocukestage_sa@evotest.govdelivery.com", "govdel01!")
    elsif ENV['XACT_ENV'] == 'prod'
      @request = HTTPI::Request.new
      @request.headers["Content-Type"] = "application/xml"
      @request.auth.basic("autocukeprod_sa@evotest.govdelivery.com", "govdel01!")
    end
end


def sample_subscriber_number
  '+16126158635'
end  
