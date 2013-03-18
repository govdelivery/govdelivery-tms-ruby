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
    self.options = CommandParameters.new(opts)
    logger.info("Performing Forward for #{options}")

    # Send the message to the external service.
    message = command.process_response(account, options, forward_response)
    
    # Send a text back to the user via twilio
    sms_service.deliver!(message, options.callback_url) if message
  end

  def forward_service
    @forward_service ||= Service::ForwardService.new
  end

  def sms_service
    return @sms_service if @sms_service
    client = Service::TwilioClient::Sms.new(self.account.sms_vendor.username, self.account.sms_vendor.password)
    @sms_service = Service::TwilioMessageService.new(client)
  end

  def account
    @account ||= Account.find(options.account_id)
  end

  def command
    @command ||= Command.find(options.command_id)
  end

  def forward_response
    forward_service.send(options.http_method.downcase, options.url, options.username, options.password, {:from => options.from, :sms_body => options.sms_body})
  end
end
