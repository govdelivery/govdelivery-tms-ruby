class RecipientsController < ApplicationController
  before_filter :find_user
  before_filter :find_type
  before_filter :find_message
  before_filter :verify_no_create_in_progress, :only => :index
  before_filter :set_page, :only => :index

  def index
    @recipients = @message.recipients.page(@page)
    set_link_header(@recipients)
  end

  def show
    @recipient = @message.recipients.find(params[:id])
  end

  protected

  def find_type
    @message_type = params.has_key?(:sms_message_id) ? "sms" : "voice"
  end

  def find_message
    @message = current_user.account_messages.find(params["#{@message_type}_message_id".to_sym])
  end

  def page_link(page)
    if page==1
      send("#{@message_type}_message_recipients_path", @message.id)
    else
      send("paged_#{@message_type}_message_recipients_path", @message.id, page)
    end
  end

  def verify_no_create_in_progress
    if Rails.cache.exist?(CreateRecipientsWorker.job_key(@message.id))
      render :json=>{:message=>'Recipient list is being built and is not yet complete'}, :status => 202 and return false
    end
  end


end
