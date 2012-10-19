class MessagesController < ApplicationController
  before_filter :find_user
  
  def show
    if @message = Message.find_by_id(params[:id])
      render :json => @message, :status => :success
    else
      render :status => :not_found
    end
  end

  def create    
    @message = @user.messages.new(params[:message])

    if @message.save
      MessageWorker.perform_async(@message.id)
      render :json => @message, :status => :accepted
    else
      render :json => @message.errors, :status => :unprocessable_entity
    end
  end

  private
  def find_user
    if @user = User.find_by_id(session[:current_user_id])
      @account = @user.account
      @vendor = @account.vendor
    end
  end
end
