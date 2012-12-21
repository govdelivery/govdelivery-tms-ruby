require 'base'

# The application having recieved an SMS from a user that maps to a "forwardable" keyword, this worker
# forwards the request to the configured external service
# and sends the response via SMS back to the user. 
#
# The external service will recieve 2 parameters (via POST body or GET url query string parameters): 
#   sms_body => The body of the incoming SMS message
#   from     => The SMS phone number of the incoming SMS message
#
# The response content type is expected to be text/plain, and the response body will be sent back 
# to the user (after being truncated to 160 characters).  If a non-200 response status is recieved, 
# the application will ignore the response body and will re-attempt the service request later.  
class ForwardWorker
  include Workers::Base
  
  attr_accessor :twilio_service, :forward_service

  # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long outage on the remote end.
  sidekiq_options retry: 25

  def perform(options)
    options = ActionParameters.new(options)
    logger.info("Performing Forward for #{options}")

    method   = options.method.downcase
    action   = options.url
    username = options.username
    password = options.password
    sms_body = options.sms_body
    from     = options.from
    account  = Account.find(options.account_id)
    
    forward_response = forward_service.send(method, action, username, password, {:from => from, :sms_body => sms_body}).body.strip

  end

  def forward_service
    @forward_service ||= ForwardService.new
  end

  def twilio_service
    @twilio_service ||= TwilioMessageService.new
  end
end
