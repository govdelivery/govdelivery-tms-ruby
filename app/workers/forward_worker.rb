require 'command_worker'

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
class ForwardWorker
  include Workers::CommandWorker

  sidekiq_options retry: false

  attr_writer :sms_service

  def perform(opts)
    self.options = opts
    message = super

    # Send a text back to the user via twilio
    sms_service.deliver!(message, options.callback_url) if message
  end

  def http_service
    @http_service ||= Service::ForwardService.new
  end

  def http_response
    begin
      return @http_response if @http_response
      @http_response = http_service.send(options.http_method.downcase, 
                                         options.url, 
                                         options.username, 
                                         options.password, 
                                         {
                                           options.from_param_name => options.from, 
                                           options.sms_body_param_name => options.sms_body
                                         })
      if @http_response.status == 0
        raise Faraday::Error::ConnectionFailed.new(nil, 
          body: "Couldn't connect to #{@http_response.env[:url].to_s}", 
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

  def sms_service
    return @sms_service if @sms_service
    client = Service::TwilioClient::Sms.new(self.account.sms_vendor.username, self.account.sms_vendor.password)
    @sms_service = Service::TwilioMessageService.new(client)
  end
end
