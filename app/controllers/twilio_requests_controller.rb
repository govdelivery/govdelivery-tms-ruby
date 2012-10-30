class TwilioRequestsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :find_vendor
  respond_to :xml

  def create
    respond_with(@vendor)
  end
  
  protected
  def find_vendor
    @vendor=Vendor.find_by_username(params['AccountSid'])
  end
end
