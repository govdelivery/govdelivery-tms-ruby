class MessagesController < ApplicationController
  
  def show
    if @message = Message.find_by_id(params[:id])
      render :json => @message, :status => :success
    else
      render :status => :not_found
    end
  end

  def create
    @message = Message.new(params[:message])

    if @message.save
      MessageWorker.perform_async(@message.id)
      render :json => @message, :status => :accepted
    else
      render :json => @message.errors, :status => :unprocessable_entity
    end
  end
end
