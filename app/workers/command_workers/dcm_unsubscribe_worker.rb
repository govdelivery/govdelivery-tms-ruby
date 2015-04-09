# This worker takes a phone number and a comma-separated list of DCM account codes
# and issues the subscriber deletion requests to DCM.  This is an account-level
# subscription deletion (i.e. not a topic unsubscribe).
module CommandWorkers
  class DcmUnsubscribeWorker
    include CommandWorkers::Base

    # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
    # That should get us through a long DCM outage (let's hope that never happens).
    # 25 is the default, but I want to be explicit so that it its understood that the
    # number is intentional.
    sidekiq_options retry: 25

    #
    # options: {"from"=>"+14445556666", "params"=>"ACME,VANDELAY"}
    #
    def perform(opts)
      super do
        client = DCMClient::Client.new(Xact::Application.config.dcm)
        number = PhoneNumber.new(options.from).dcm

        # take the HTTP response with the highest response code
        command.params.dcm_account_codes.collect do |dcm_account_code|
          begin
            self.http_response = client.delete_wireless_subscriber(number, dcm_account_code)
          # we don't care if the DCM subscriber doesn't exist
          rescue DCMClient::Error::NotFound => e
            self.http_response = e.response
          # store exception and mark job as failed even though we'll retry it
          rescue DCMClient::Error => e
            logger.error e.message
            self.exception     = e
            self.http_response = e.response
          end
        end
      end

    ensure
      raise exception if exception
    end

    ##
    # If any of the http requests in this batch succeeds, this
    # worker should report success.
    #
    def http_response=(response)
      if @http_response.nil? || @http_response.status > response.status
        @http_response = response
      end
    end
  end
end
