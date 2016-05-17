class MessageTypesController < ApplicationController
  before_action :find_user
  before_action :find_message_type, except: [:index, :create]
  wrap_parameters :message_type, include: [:label, :code], format: [:json, :url_encoded_form]

  def index
    @message_types = @account.message_types.page(params[:page])
    respond_with(@message_types)
  end

  def create
    respond_with(@message_type = @account.message_types.create(params[:message_type]))
  end

  def update
    @message_type.update_attributes(params[:message_type])
    respond_with(@message_type)
  end

  def destroy
    if @message_type.email_templates.count == 0
      # todo check for messages
      @message_type.destroy
      render status: 204, nothing: true
    else
      render status: 422, text: 'a Message type with message templates can not be deleted'
    end
  end

  protected

  def find_message_type
    @message_type = @account.message_types.find(params[:id])
  end
end
