class MessagesController < ApplicationController  
  def show
    @message = Message.find(params[:id])
    render json: @message
  end

  def create
    @message = Message.new(params[:message])

    if @message.save
      MessageWorker.perform_async(@message.id)
      render :json => @message, :status => :accepted, :location => @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end
end
