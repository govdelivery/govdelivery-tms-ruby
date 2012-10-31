class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :find_vendor, :build_response
  respond_to :xml

  def create
    @vendor.stop_requests.create!(:from => params['From']) if @twilio_request_response.stop?
    respond_with(@twilio_request_response)
  end
  
  protected
  def find_vendor
    @vendor=Vendor.find_by_username!(params['AccountSid'])
  end

  def build_response
    @twilio_request_response = View::TwilioRequestResponse.new(:vendor => @vendor, :request => params['Body'])
  end
end
