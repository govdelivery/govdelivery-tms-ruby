class MessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, :only => :index

  def index
    @messages = current_user.account.messages.page(@page)
    set_link_header(@messages)
    respond_with(@messages)
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
    @message = current_user.new_message(params[:message])
    if @message.save
      @message.create_recipients(recipients) unless recipients.nil?
      options = {:message_id => @message.id}
      options[:callback_url] = twilio_status_callbacks_url(:format => :xml) if Rails.configuration.public_callback
      options[:message_url] = twiml_url
      @message.worker.send(:perform_async, options)
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
