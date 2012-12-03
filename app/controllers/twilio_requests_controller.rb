class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :xml

  def create
    respond_with(twilio_request_response)
  end

  private

  def twilio_request_response
    vendor = find_vendor
    sms_receiver = SmsReceiver.new(vendor, vendor.stop_text, vendor.help_text)
    sms_receiver.keywords = vendor.keywords
    response_text = sms_receiver.respond_to_sms!(params['From'], params['Body'])
    @response = View::TwilioRequestResponse.new(vendor, response_text)
  end

  def find_vendor
    Vendor.find_by_username!(params['AccountSid'])
  end
end
