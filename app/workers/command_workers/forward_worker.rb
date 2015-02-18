# The application having recieved an SMS from a user that maps to a "forwardable" keyword, this worker
# forwards the request to the configured external service
# and sends the response via SMS back to the user.
#
# The external service will recieve 2 parameters (via POST body or GET url query string parameters):
#   sms_body => The body of the incoming SMS message
#   from     => The SMS phone number of the incoming SMS message
#
# The response content type is expected to be text/plain, and the response body will be sent back
# to the user (after being truncated to 160 characters).
#
# Unlike other commands, if a non-200 response status is received, we don't retry.
module CommandWorkers
  class ForwardWorker
    include CommandWorkers::Base

    sidekiq_options retry: 3, queue: :webhook
    sidekiq_retry_in { 10 }

    attr_writer :sms_service

    def perform(opts)
      begin
        callback_url = nil
        message = super do
          self.http_response = send_request(self.options, self.command.params)
          callback_url = options.callback_url
        end

        if message
          recipient_id = message.first_recipient_id
          logger.info("ForwardWorker: responding to #{recipient_id} with #{message.attributes.inspect}")
          send_response(message, recipient_id, callback_url)
        end
      rescue Faraday::ClientError => e
        ActiveRecord::Base.transaction do
          if e.response
            # ClientError#response isn't really a response, so...
            e.response[:response_headers] = e.response.delete(:headers)
            @command.process_response(self.options, Faraday::Response.new(Faraday::Env.from(e.response)))
          else
            @command.process_error(self.options, e.message)
          end
        end
        raise
      rescue => e
        raise Sidekiq::Retries::Fail.new(e)
      end
    end

    def send_response(message, recipient_id, callback_url)
      message.responding!
      Twilio::SenderWorker.perform_async(message_class: message.class.name,
                                         callback_url:  callback_url,
                                         message_id:    message.id,
                                         recipient_id:  recipient_id)
    end

    def http_service
      @http_service ||= Service::ForwardService.new(self.logger)
    end

    def send_request(options, command_params)
      sms_body = command_params.strip_keyword ? options.sms_tokens.join(" ") : options.sms_body
      response = http_service.send(command_params.http_method.downcase,
                                   command_params.url,
                                   command_params.username,
                                   command_params.password,
                                   {
                                     command_params.from_param_name     => options.from,
                                     command_params.sms_body_param_name => sms_body
                                   })
      if response.status == 0
        return OpenStruct.new(
          body:    "Couldn't connect to #{@http_response.env[:url].to_s}",
          headers: {}
        )
      end
      return response
    end
  end
end