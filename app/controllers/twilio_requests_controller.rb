class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_user_from_token!
  before_filter :dcm_forward!
  respond_to :xml

  def create
    respond_with(twilio_request_response)
  end

  private

  def twilio_request_response
    vendor         = find_vendor
    command_parameters = CommandParameters.new(sms_body: params['Body'],
                                               to:           params['To'],
                                               from:         params['From'],
                                               callback_url: callback_url)


    #parse it
    prefix, keyword_service, message, account_id = InboundSmsParser.parse(params['Body'], vendor)

    #store it
    inbound_msg = vendor.create_inbound_message!({ from:  command_parameters.from,
                                                   to:    command_parameters.to,
                                                   body:  command_parameters.sms_body,
                                                   account_id: account_id,  #used for scoped reporting, can be blank
                                                   keyword: keyword_service.keyword,
                                                   keyword_response: keyword_service.response_text})

    command_parameters.merge!(sms_tokens:         message.split,
                              inbound_message_id: inbound_msg.id)
    response_text = keyword_service.respond!(command_parameters)

    if inbound_msg.ignored? # to not respond to auto responses
      Rails.logger.info "ignoring message: #{inbound_msg.inspect}"
      response_text = nil
    end

    # if response_text is empty, twillio will not send a response
    @response      = View::TwilioRequestResponse.new(vendor, response_text)
  end

  def find_vendor
    SmsVendor.find_by_username_and_from_phone!(params['AccountSid'], params['To'])
  end

  def callback_url
    twilio_status_callbacks_url(:format => :xml) if Rails.configuration.public_callback
  end

  private

  # This is a hack and is intended to be temporary.
  def dcm_forward!
    ForwardStopsToDcm.forward_async!(params)
  end
end
