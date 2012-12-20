require 'base'
# This worker takes a phone number and a comma-separated list of DCM account codes
# and issues the subscriber deletion requests to DCM.  This is an account-level 
# subscription deletion (i.e. not a topic unsubscribe).
class DcmUnsubscribeWorker
  include Workers::Base
  
  # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long DCM outage (let's hope that never happens).
  # 25 is the default, but I want to be explicit so that it its understood that the 
  # number is intentional.
  sidekiq_options retry: 25
  
  #
  # options: {"from"=>"+14445556666", "params"=>"ACME,VANDELAY"}
  #
  def perform(options)
    options = ActionParameters.new(options)
    logger.info("Performing DCM unsubscribe for #{options.to_s}")

    client = DCMClient::Client.new(Tsms::Application.config.dcm)
    number = PhoneNumber.new(options.from).dcm

    options.dcm_account_codes.each do |account_code|
      begin
        client.delete_wireless_subscriber(number, account_code)
      
      # we don't care if the DCM subscriber doesn't exist
      rescue DCMClient::Error::NotFound => e
      
      # we DO care about other client errors, but let's log them first. 
      rescue DCMClient::Error => e
        logger.error e.message
        logger.error e.response.inspect
        # backtrace will go to STDOUT, we don't need it in the log
        raise e
      end
    end
  end
end
