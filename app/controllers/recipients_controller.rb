class RecipientsController < ApplicationController
  before_filter :find_user
  before_filter :find_message
  before_filter :verify_no_create_in_progress, :only => :index
  before_filter :set_page, :only => [:index, :clicked, :opened]

  def index
    @recipients = @message.recipients.page(@page)
    set_link_header(@recipients)
  end

  def show
    @recipient = @message.recipients.find(params[:id])
  end

  def clicked
    render_recipient_subset(:clicked)
  end

  def opened
    render_recipient_subset(:opened)
  end

  protected

  def render_recipient_subset(type)
    @recipients = @message.send(:"recipients_who_#{type}").page(@page)
    set_link_header(@recipients)
    render :index
  end

  def find_message
    if params[:sms_id]
      @message = current_user.account_sms_messages.find(params[:sms_id])
      set_phone_recipient_attributes
    elsif params[:voice_id]
      @message = current_user.account_voice_messages.find(params[:voice_id])
      set_phone_recipient_attributes
    elsif params[:email_id]
      @message = current_user.account_email_messages.find(params[:email_id])
      set_email_recipient_attributes
    end
  end

  def verify_no_create_in_progress
    if (Rails.cache.exist?(CreateRecipientsWorker.job_key(@message.id)) rescue false)
      render :json => {:message => 'Recipient list is being built and is not yet complete'}, :status => 202 and return false
    end
  end

  def set_phone_recipient_attributes
    @content_attributes = [:formatted_phone, :phone]
  end

  def set_email_recipient_attributes
    @content_attributes = [:email, :macros]
  end

end
