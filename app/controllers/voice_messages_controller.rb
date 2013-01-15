class VoiceMessagesController < MessagesController
  include FeatureChecker
  feature :voice

  wrap_parameters :message, :include => [:play_url, :recipients], :format => :json

  protected

  def set_scope
    @message_scope = current_user.voice_messages
  end

  def set_attr
    @content_attribute = :play_url
  end
end