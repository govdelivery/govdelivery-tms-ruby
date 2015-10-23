class IncomingVoiceMessagesController < ApplicationController
  include FeatureChecker
  wrap_parameters :incoming_voice_message, include: [:from_number, :say_text, :play_url, :is_default, :expires_in], format: [:json, :url_encoded_form]
  before_action :find_user
  before_action :find_from_number, only: [:create]
  before_action :find_voice_message, only: [:show]
  feature :voice

  def index
    @voice_messages = @account.incoming_voice_messages.page(@page)
    set_link_header(@voice_messages)
  end

  def show
  end

  def create
    @voice_message = @from_number.incoming_voice_messages.new(params[:incoming_voice_message])
    @voice_message.save
    respond_with(@voice_message)
  end

  private

  def find_from_number
    Rails.logger.info params.inspect
    @from_number = @account.from_numbers.where('phone_number = ?', params[:phone_number]).first
  end

  def find_voice_message
    @voice_message = @account.incoming_voice_messages.find(params[:id])
  end
end
