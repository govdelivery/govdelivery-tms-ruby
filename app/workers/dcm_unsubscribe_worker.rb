# This worker takes a phone number and a comma-separated list of DCM account codes
# and issues the subscriber deletion requests to DCM.  This is an account-level 
# subscription deletion (i.e. not a topic unsubscribe).
class DcmUnsubscribeWorker
  include Sidekiq::Worker
  
  # Retry for up to ~ 4 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long DCM outage (let's hope that never happens).
  # 25 is the default, but I want to be explicit so that it its understood that the 
  # number is intentional.
  sidekiq_options retry: 25
  
  #
  # options: {"from"=>"+14445556666", "params"=>"ACME,VANDELAY"}
  #
  def perform(options)
    logger.info("Performing DCM unsubscribe for #{options.inspect}")

    client = DCMClient::Client.new(Tsms::Application.config.dcm)
    number = PhoneNumber.new(options["from"]).dcm

    begin
      options["params"].split(",").each do |account_code|
        client.delete_wireless_subscriber(number, account_code)
      rescue Faraday::Error::ResourceNotFound => e
        # we don't care if the DCM subscriber doesn't exist
      end
    end
  end
end
