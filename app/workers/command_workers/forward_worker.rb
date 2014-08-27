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

    sidekiq_options retry:    0,
                    queue:    :webhook,
                    throttle: {threshold: 30,
                               period:    5.seconds,
                               key:       ->(options) { Addressable::URI.parse(options['url']).host }}

    attr_writer :sms_service

    def perform(opts)
      self.options = opts
      # message is returns from CommandType::Forward#process_response
      # only one recipient is created
      message      = super

      if message
        recipient_id = message.first_recipient_id
        logger.info("ForwardWorker: responding to #{recipient_id} with #{message.attributes.inspect}")
        # Send a text back to the user via twilio
        send_response(message, recipient_id, options.callback_url)
      end
    end

    def send_response(message, recipient_id, callback_url)
      message.sending!
      Twilio::SenderWorker.perform_async(message_class: message.class.name,
                                         callback_url:  callback_url,
                                         message_id:    message.id,
                                         recipient_id:  recipient_id)
    end

    def http_service
      @http_service ||= Service::ForwardService.new
    end

    def http_response
      begin
        return @http_response if @http_response

        # If the command was configured to strip the keyword, we use sms_tokens
        # (which is an array of tokens in the sms body, minus the detected keyword).  Otherwise,
        # we pass along the body unmolested.
        sms_body = options.strip_keyword ? options.sms_tokens.join(" ") : options.sms_body

        @http_response = http_service.send(options.http_method.downcase,
                                           options.url,
                                           options.username,
                                           options.password,
                                           {
                                             options.from_param_name     => options.from,
                                             options.sms_body_param_name => sms_body
                                           })
        if @http_response.status == 0
          raise Faraday::Error::ConnectionFailed.new(nil,
                                                     body:    "Couldn't connect to #{@http_response.env[:url].to_s}",
                                                     headers: {})
        end
      rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError => e
        # these are network problems, they could happen because of a bad command but we should probably know about them
        # in case e.g. our network is having issues
        self.exception = e
        @http_response = OpenStruct.new(e.response)
      rescue Faraday::Error::ClientError => e
        # anything that isn't potentially a network problem is marked as a failure without reraising
        @http_response = OpenStruct.new(e.response)
      ensure
        return @http_response
      end
    end
  end
end