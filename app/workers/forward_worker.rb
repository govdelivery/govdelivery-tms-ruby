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
  
  attr_accessor :sms_service, :forward_service, :options, :account

  # Retry for up to ~ 20 days (see https://github.com/mperham/sidekiq/wiki/Error-Handling)
  # That should get us through a long outage on the remote end.
  sidekiq_options retry: 25

  def perform(opts)
    self.options = ActionParameters.new(opts)
    logger.info("Performing Forward for #{options}")

    http_method  = options.http_method.downcase
    action       = options.url
    username     = options.username
    password     = options.password
    sms_body     = options.sms_body
    from         = options.from
    callback_url = options.callback_url
    self.account = Account.find(options.account_id)
    
    # Send the message to the external service.  
    forward_response = forward_service.send(http_method, action, username, password, {:from => from, :sms_body => sms_body}).body.strip

    # Build an SMS message with the response of the previous HTTP call. 
    message = build_message(forward_response)
    
    # Send a text back to the user via twilio
    sms_service.deliver!(message, callback_url)
  end

  def forward_service
    @forward_service ||= Service::ForwardService.new
  end

  def build_message(short_body)
    message = account.messages.new(:short_body => short_body)
    # User is out of context for this message, as there is no current user - the 
    # incoming controller request was from a handset (not a client's app)
    message.recipients.build(:phone => options.from, :vendor => account.sms_vendor)
    message.save!
    message
  end

  def sms_service
    @sms_service ||= Service::TwilioSmsMessageService.new(self.account.sms_vendor.username, self.account.sms_vendor.password)
  end
end
