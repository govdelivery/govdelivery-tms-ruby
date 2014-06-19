class InboundMessagesController < ApplicationController
  include FeatureChecker
  before_filter :find_user
  before_filter :set_page, :only => :index
  feature :sms

  # GET /inbound_messages
  def index
    @messages = finder.page(@page)
    set_link_header(@messages)
  end

  # GET /inbound_messages/1
  def show
    @message = finder.find(params[:id])
  end

  protected

  def finder
    current_user.sms_vendor.inbound_messages.
      includes(:command_actions).
      where(account_id: current_user.account.id)
  end

end
