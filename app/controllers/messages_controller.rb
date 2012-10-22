class MessagesController < ApplicationController
  before_filter :find_user

  def show
    if @message = @user.messages.find_by_id(params[:id])
      render
    else
      render :json => {:error => "Not Found"}.to_json, :status => :not_found
    end
  end

  def create
    @message = @user.messages.new(params[:message])
    if @message.save
      @user.vendor.worker.constantize.send(:perform_async, @message.id)
    end
    render
  end

  private
  def find_user
    if @user = User.find_by_id(session[:current_user_id])
      @account = @user.account
      @vendor = @account.vendor
    end
  end
end
