class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :find_vendor, :build_response
  respond_to :xml

  def create
    respond_with(@twilio_request_response)
  end

  protected
  def find_vendor
    @vendor=Vendor.find_by_username!(params['AccountSid'])
  end

  def build_response
    @request_parser          = RequestParser.new(@vendor, params['Body'], params['From']).parse!
    @twilio_request_response = View::TwilioRequestResponse.new(@vendor, @request_parser)
  end
end
