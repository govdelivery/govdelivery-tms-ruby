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


def environment
    if !ENV.has_key?('XACT_ENV') or ENV['XACT_ENV'] == 'dev'
        "http://localhost:3000"
    elsif ENV['XACT_ENV'] == 'qc'
        "https://qc-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'int'
        "https://int-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'stage'
        "https://stage-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'prod'
        "https://tms.govdelivery.com"
    end
end

def callbacks_api_root
    'http://xact-webhook-callbacks.herokuapp.com/api/v2/'
end

def tms_client
  if ENV['XACT_ENV'].nil? or ENV['XACT_ENV'] == 'dev'
    TMS::Client.new(ENV['XACT_TOKEN'], :api_root => environment)
  elsif ENV['XACT_ENV'] == 'qc'
    client = TMS::Client.new('gqaGqJJ696x3MrG7CLCHqx4zNTGmyaEp', :api_root => environment)
  elsif ENV['XACT_ENV'] == 'int'
    "http://int-tms.govdelivery.com"
  elsif ENV['XACT_ENV'] == 'stage'
    "http://stage-tms.govdelivery.com"
  elsif ENV['XACT_ENV'] == 'prod'
    "http://tms.govdelivery.com"
  end
end