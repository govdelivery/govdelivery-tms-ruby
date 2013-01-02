class RecipientsController < ApplicationController
  before_filter :find_user
  before_filter :find_message
  before_filter :set_page, :only => :index

  def index
    @recipients = @message.recipients.page(@page)
    set_link_header(@recipients)
  end

  def show
    @recipient = @message.recipients.find(params[:id])
  end

  protected

  def find_message
    @message = current_user.account_messages.find(params[:message_id])
  end

  def page_link(page)
    if page==1
      message_recipients_path(@message.id)
    else
      paged_message_recipients_path(@message.id, page)
    end
  end


end
