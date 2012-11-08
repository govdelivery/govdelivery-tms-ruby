class MessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, :only => :index

  def index
    @messages = current_user.messages.page(@page)
    set_link_header(@messages)
    respond_with(@message)
  end

  def new
    @message = current_user.messages.build
    render :show
  end

  def show
    @message = current_user.messages.find_by_id(params[:id])
    respond_with(@message)
  end

  def create
    recipients = params[:message].delete(:recipients) if params[:message]
    @message = current_user.messages.new(params[:message])
    if @message.save
      @message.create_recipients(recipients) unless recipients.nil?
      current_user.vendor.worker.constantize.send(:perform_async, {:message_id => @message.id, :callback_url => twilio_status_callbacks_url(:format => :xml)})
    end
    respond_with(@message)
  end

  private
 
  def page_link(page)
    if page==1
      messages_path
    else
      paged_messages_path(page)
    end
  end

end
