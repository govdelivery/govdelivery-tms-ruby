class MessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, :only => :index
  before_filter :set_scope, :except => :create
  before_filter :set_attr

  def index
    @messages = @message_scope.page(@page)
    set_link_header(@messages)
    respond_with(@messages)
  end

  def new
    @messages = @message_scope.build
    render :show
  end

  def show
    @messages = @message_scope.find_by_id(params[:id])
    respond_with(@message)
  end

  def create
    recipients = params[:message].delete(:recipients) if params[:message]
    @message = current_user.new_message(params[:message])
    if @message.save
      Rails.cache.write(CreateRecipientsWorker.job_key(@message.id), 1)
      CreateRecipientsWorker.send(:perform_async, {:recipients => recipients, :message_id => @message.id, :send_options => send_options})
    end
    respond_with(@message)
  end

  private
  def set_scope
    raise "@message_scope must be set in MessagesController subclass"
  end

  def set_attr
    raise "@content_attribute must be set in MessagesController subclass"
  end

  def send_options
    opts = {:message_url => twiml_url}
    opts[:callback_url] = twilio_status_callbacks_url(:format => :xml) if Rails.configuration.public_callback
    opts
  end

end
