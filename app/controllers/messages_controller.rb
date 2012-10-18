class MessagesController < ApplicationController
  
  def show
    if @message = Message.find(params[:id])
      render :json => @message, :status => :success
    else
      render :nothing, :status => :not_found
    end
  end

  def create
    @message = Message.new(params[:message])

    if @message.save
      MessageWorker.perform_async(@message.id)
      render :json => @message, :status => :accepted
    else
      render json: @message.errors, :status => :unprocessable_entity
    end
  end
end
