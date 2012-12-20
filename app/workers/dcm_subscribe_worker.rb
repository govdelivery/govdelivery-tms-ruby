require 'base'

class DcmSubscribeWorker
  include Workers::Base

  # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long DCM outage (let's hope that never happens).
  # 25 is the default, but I want to be explicit so that it its understood that the 
  # number is intentional.
  sidekiq_options retry: 25

  #
  # options: {"from"=>"+14445556666", "params"=>"ACME:TOPIC_1,TOPIC_2"}
  #
  def perform(options)
    options = ActionParameters.new(options)
    logger.info("Performing DCM subscribe for #{options}")

    client = DCMClient::Client.new(Tsms::Application.config.dcm)

    DcmSubscribeAction.new(client).call(options.from, options.dcm_account_code, options.dcm_topic_codes, options.sms_tokens)

  # DO NOT retry if the response is an Unprocessable Entity
  rescue DCMClient::Error::UnprocessableEntity => e
    logger.error "message: #{e.message}\nresponse: #{e.response.inspect}"

  # DO retry other client errors, but log them first. 
  rescue DCMClient::Error => e
    logger.error "message: #{e.message}\nresponse: #{e.response.inspect}"
    # backtrace will go to STDOUT, we don't need it in the log
    raise e
  end
end

