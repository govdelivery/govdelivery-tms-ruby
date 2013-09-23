class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate
  respond_to :xml

  def create
    respond_with(twilio_request_response)
  end

  private

  def twilio_request_response
    vendor         = find_vendor
    command_params = CommandParameters.new(:sms_body => params['Body'], :to => params['To'], :from => params['From'], :callback_url => callback_url)
    response_text  = SmsReceiver.new(vendor, command_params).respond_to_sms!
    @response      = View::TwilioRequestResponse.new(vendor, response_text)
  end

  def find_vendor
    SmsVendor.find_by_username_and_from_phone!(params['AccountSid'], params['To'])
  end

  def callback_url
    twilio_status_callbacks_url(:format => :xml) if Rails.configuration.public_callback
  end
end
