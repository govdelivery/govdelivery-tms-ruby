class RecipientsController < ApplicationController
  before_action :find_user
  before_action :find_message
  before_action :verify_no_create_in_progress, only: :index
  before_action :set_page, except: [:show]

  def index
    @recipients = @message.recipients.page(@page)
    set_link_header(@recipients)
  end

  def show
    @recipient = @message.recipients.find(params[:id])
  end

  # email
  def clicked
    render_recipient_subset(:clicked)
  end

  # email
  def opened
    render_recipient_subset(:opened)
  end

  # sms,voice,email
  def failed
    render_recipient_subset(:failed)
  end

  # sms,voice,email
  def sent
    render_recipient_subset(:sent)
  end

  # voice
  def human
    render_recipient_subset(:human)
  end

  # voice
  def machine
    render_recipient_subset(:machine)
  end

  # voice
  def busy
    render_recipient_subset(:busy)
  end

  # voice
  def no_answer
    render_recipient_subset(:no_answer)
  end

  # voice
  def could_not_connect
    render_recipient_subset(:could_not_connect)
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
      set_sms_recipient_attributes
    elsif params[:voice_id]
      @message = current_user.account_voice_messages.find(params[:voice_id])
      set_voice_recipient_attributes
    elsif params[:email_id]
      @message = current_user.account_email_messages.find(params[:email_id])
      set_email_recipient_attributes
    end
  end

  def verify_no_create_in_progress
    if Rails.cache.exist?(CreateRecipientsWorker.job_key(@message.id))
      render json: {message: 'Recipient list is being built and is not yet complete'}, status: 202
      return false
    end
  end

  def set_sms_recipient_attributes
    @content_attributes = [:formatted_phone, :phone]
  end

  def set_voice_recipient_attributes
    @content_attributes = [:formatted_phone, :phone, :secondary_status, :retries]
  end

  def set_email_recipient_attributes
    @content_attributes = [:email, :macros]
  end
end
