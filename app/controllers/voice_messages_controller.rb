class VoiceMessagesController < MessagesController

  protected

  def set_scope
    @message_scope = current_user.voice_messages
  end

  def set_attr
    @content_attribute = :url
  end
end