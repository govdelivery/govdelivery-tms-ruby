class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate
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
    prefix, keyword, message, account_id = InboundSmsParser.parse(params['Body'], vendor)
    Rails.logger.debug "parsed keyword: #{keyword.name}"

    #store it
    inbound_msg = vendor.create_inbound_message!({ from:  command_parameters.from,
                                                   to:    command_parameters.to,
                                                   body:  command_parameters.sms_body,
                                                   account_id: account_id,  #used for scoped reporting, can be blank
                                                   keyword: keyword,
                                                   keyword_response: keyword.try(:response_text)})

    # respond to it (now and/or later)
    if inbound_msg.ignored? # to not respond to auto responses
      Rails.logger.debug "ignoring message: #{inbound_msg.inspect}"
      response_text = nil
    else
      command_parameters.merge!(account_id: account_id,
                                sms_tokens: message.split,
                                inbound_message_id: inbound_msg.id)
      response_text  = SmsReceiver.respond_to_sms!(keyword, command_parameters)
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
