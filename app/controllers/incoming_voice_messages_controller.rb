class IncomingVoiceMessagesController < ApplicationController
  include FeatureChecker
  wrap_parameters :incoming_voice_message, include: [:from_number, :say_text, :play_url, :is_default], format: [:json, :url_encoded_form]
  before_filter :find_user
  before_filter :find_voice_message, :only => [:show, :update]
  before_filter :set_page, :only => :index
  feature :voice

  def index
    @voice_messages = @account.incoming_voice_messages.page(@page)
    set_link_header(@voice_messages)
  end

  def show
  end

  def create
    @voice_message = @account.incoming_voice_messages.new(params[:incoming_voice_message])
    @voice_message.save
    respond_with(@voice_message)
  end

  private

  def find_voice_message
    @voice_message = @account.incoming_voice_messages.find(params[:id])
  end
end
