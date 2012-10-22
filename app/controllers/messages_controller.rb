class MessagesController < ApplicationController
  before_filter :find_user

  def show
    if @message = current_user.messages.find_by_id(params[:id])
      render
    else
      render :json => {:error => "Not Found"}.to_json, :status => :not_found
    end
  end

  def create
    recipients = params[:message].delete(:recipients) if params[:message]
    @message = current_user.messages.new(params[:message])
    if @message.save
      recipients.each {|recipient| @message.recipients.create(recipient)} if recipients
      current_user.vendor.worker.constantize.send(:perform_async, @message.id)
    end
    render
  end

  private
  def find_user
    if user_signed_in?
      @account = current_user.account
      @vendor = @account.vendor
    end
  end
end
