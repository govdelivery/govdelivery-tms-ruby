module CommandWorkers
  class DcmSubscribeWorker
    include CommandWorkers::Base

    # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
    # That should get us through a long DCM outage (let's hope that never happens).
    # 25 is the default, but I want to be explicit so that it its understood that the
    # number is intentional.
    sidekiq_options retry: 25

    # Note: this uses dcm_account_code SINGULAR
    #       the stop worker uses dcm_account_codes PLURAL
    # options: {"from"=>"+14445556666", "params"=>"ACME:TOPIC_1,TOPIC_2"}
    #
    def perform(opts)
      super do
        begin
          client             = DCMClient::Client.new(Xact::Application.config.dcm)
          from_number        = PhoneNumber.new(options.from).dcm
          self.http_response = request_subscription(client, from_number, options, command.params)

        rescue DCMClient::Error::UnprocessableEntity, DCMClient::Error::NotFound => e
          # don't raise exception, so no retry
          logger.error "message: #{e.message}\nresponse: #{e.response.inspect}"
          self.http_response = e.response

        rescue DCMClient::Error => e
          # retry job, but mark as failed first
          logger.error "message: #{e.message}\nresponse: #{e.response.inspect}"

          self.http_response = e.response
          self.exception     = e
        end
      end

    ensure
      raise self.exception if self.exception
    end

    def request_subscription client, from_number, options, command_parameters
      if (email_address = extract_email(options.sms_tokens || []))
        # example: subscribe em@il
        client.email_subscribe(email_address, command_parameters.dcm_account_code, command_parameters.dcm_topic_codes)
      else
        client.wireless_subscribe(from_number, command_parameters.dcm_account_code, command_parameters.dcm_topic_codes)
      end
    end

    def extract_email(subscribe_args)
      if !subscribe_args[0].nil? && subscribe_args[0] =~ /@/
        subscribe_args[0]
      end
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
