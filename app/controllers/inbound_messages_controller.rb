class InboundMessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, :only => :index

  # GET /inbound_messages
  def index
    @messages = current_user.account.vendors.first.inbound_messages.page(@page)
    set_link_header(@messages)
  end

  # GET /inbound_messages/1
  def show
    @message = current_user.account.vendors.first.inbound_messages.find(params[:id])
  end

  protected

  def page_link(page)
    if page==1
      inbound_messages_path
    else
      paged_inbound_messages_path(page)
    end
  end
end
