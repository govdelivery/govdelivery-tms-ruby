class TwilioRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  respond_to :xml
  attr_writer :handler

  def create
    respond_with(twilio_request_response)
  end

  private

  def twilio_request_response
    response_text = handler.handle(params['MessageSid'], params['To'], params['From'], params['Body']) ? handler.response_text : nil
    @response     = View::TwilioRequestResponse.new(handler.vendor, response_text)
  end

  def callback_url
    twilio_status_callbacks_url(format: :xml) if Rails.configuration.public_callback
  end

  def handler
    @handler ||= InboundMessageHandler.new(SmsVendor.where(username: params['AccountSid']))
  end
end
