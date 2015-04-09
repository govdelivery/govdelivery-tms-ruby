class MessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_scope
  before_filter :set_attr

  def index
    @messages = @message_scope.page(@page)
    set_link_header(@messages)
    respond_with(@messages)
  end

  def new
    @message = @message_scope.build
    render :show
  end

  def show
    @message = @message_scope.find(params[:id])
    respond_with(@message)
  end

  def create
    params[:message][:async_recipients] = params[:message].delete(:recipients) if params[:message]
    @message = @message_scope.build(params[:message])
    if @message.save_with_async_recipients
      CreateRecipientsWorker.perform_async(recipients: @message.async_recipients,
                                           klass:        @message.class.name,
                                           message_id:   @message.id,
                                           send_options: send_options)
    end
    respond_with(@message)
  end

  protected

  def set_scope
    raise '@message_scope must be set in MessagesController subclass'
  end

  def set_attr
    raise '@content_attribute must be set in MessagesController subclass'
  end

  def send_options
    opts = { message_url: twiml_url }
    opts[:callback_url] = twilio_status_callbacks_url(format: :xml) if Rails.configuration.public_callback
    opts
  end
end
