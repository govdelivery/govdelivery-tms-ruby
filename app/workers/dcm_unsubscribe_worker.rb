require 'command_worker'
# This worker takes a phone number and a comma-separated list of DCM account codes
# and issues the subscriber deletion requests to DCM.  This is an account-level 
# subscription deletion (i.e. not a topic unsubscribe).
class DcmUnsubscribeWorker
  include Workers::CommandWorker

  # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long DCM outage (let's hope that never happens).
  # 25 is the default, but I want to be explicit so that it its understood that the 
  # number is intentional.
  sidekiq_options retry: 25

  #
  # options: {"from"=>"+14445556666", "params"=>"ACME,VANDELAY"}
  #
  def perform(opts)
    self.options = opts

    client = DCMClient::Client.new(Xact::Application.config.dcm)
    number = PhoneNumber.new(options.from).dcm

    # take the HTTP response with the highest response code
    #
    self.http_response = options.dcm_account_codes.collect do |account_code|
      begin
        client.delete_wireless_subscriber(number, account_code)
      # we don't care if the DCM subscriber doesn't exist
      rescue DCMClient::Error::NotFound => e
        e.response
      # store exception and mark job as failed even though we'll retry it
      rescue DCMClient::Error => e
        logger.error e.message
        self.exception = e
        e.response
      end
    end.max_by(&:status)

    super
  ensure
    raise self.exception if self.exception
  end
end
