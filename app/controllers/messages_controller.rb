class MessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, :only => :index

  def index
    set_link_header(@messages)
    respond_with(@messages)
  end

  def new
    render :show
  end

  def show
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

  def page_link(page)
    if page==1
      send("#{controller_name}_path")
    else
      send("paged_#{controller_name}_path", page)
    end
  end

  def send_options
    opts = {:message_url => twiml_url}
    opts[:callback_url] = twilio_status_callbacks_url(:format => :xml) if Rails.configuration.public_callback
    opts
  end

end
