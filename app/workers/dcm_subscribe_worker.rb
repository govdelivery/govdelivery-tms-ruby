require 'command_worker'

class DcmSubscribeWorker
  include Workers::CommandWorker

  # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long DCM outage (let's hope that never happens).
  # 25 is the default, but I want to be explicit so that it its understood that the 
  # number is intentional.
  sidekiq_options retry: 25

  #
  # options: {"from"=>"+14445556666", "params"=>"ACME:TOPIC_1,TOPIC_2"}
  #
  def perform(opts)
    Xact::Application.config.dcm.each do |config|
      begin
        self.options = opts
        client = DCMClient::Client.new(config)
        self.http_response = DcmSubscribeCommand.new(client).call(options.from, options.dcm_account_code, options.dcm_topic_codes, options.sms_tokens)

      rescue DCMClient::Error::UnprocessableEntity, DCMClient::Error::NotFound => e
        # don't raise exception, so no retry
        logger.error "message: #{e.message}\nresponse: #{e.response.inspect}"
        self.http_response = e.response

      rescue DCMClient::Error => e
        # retry job, but mark as failed first
        logger.error "message: #{e.message}\nresponse: #{e.response.inspect}"

        self.http_response = e.response
        self.exception = e
      end
    end

    super

  ensure
    raise self.exception if self.exception
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

