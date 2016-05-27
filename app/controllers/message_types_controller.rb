class MessageTypesController < ApplicationController
  before_action :find_user
  
  include FeatureChecker
  feature :email

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
    @message_type.destroy
    respond_with(@message_type)
  end

  protected

  def find_message_type
    @message_type = @account.message_types.find(params[:id])
  end
end