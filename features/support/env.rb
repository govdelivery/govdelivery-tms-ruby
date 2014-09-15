require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'tms_client'
  

#pass environment variables to control which browser is used for testing. Default is HEADLESS/POLTERGEIST
#usage: FIREFOX=true bundle exec cucumber features/test.feature

# Before do 
#   $dunit ||= false  # have to define a variable before we can reference its value
#   return $dunit if $dunit                  # bail if $dunit TRUE
#   step "run the really slow log in method" # otherwise do it.
#   $dunit = true                            # don't do it again.
# end 



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
        "http://qc-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'int'
        "http://int-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'stage'
        "http://stage-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'prod'
        "http://tms.govdelivery.com"
    end
end

def callbacks_api_root
    'http://xact-webhook-callbacks.herokuapp.com/api/v2/'
end