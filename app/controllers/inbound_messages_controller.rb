class InboundMessagesController < ApplicationController
  include FeatureChecker
  before_filter :find_user
  before_filter :set_page, :only => :index
  feature :sms
  
  # GET /inbound_messages
  def index
    @messages = current_user.sms_vendor.inbound_messages.page(@page)
    set_link_header(@messages)
  end

  # GET /inbound_messages/1
  def show
    @message = current_user.sms_vendor.inbound_messages.find(params[:id])
  end

end