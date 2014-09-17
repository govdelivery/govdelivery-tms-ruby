require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'tms_client'
<<<<<<< HEAD
=======
  



>>>>>>> 6a4963545918b0e16996ad85879c195edacd5c6a


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
    if !ENV.has_key?('XACT_ENV') | ENV['XACT_ENV'] == 'dev'
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
<<<<<<< HEAD
end
=======
end
>>>>>>> 6a4963545918b0e16996ad85879c195edacd5c6a
