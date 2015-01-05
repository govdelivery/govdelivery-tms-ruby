class VoiceMessagesController < MessagesController
  include FeatureChecker
  feature :voice

  wrap_parameters :message, include: [:say_text, :play_url, :retries, :retry_url, :recipients, :from_number], format: [:json, :url_encoded_form]

  protected

  def set_scope
    @message_scope = current_user.voice_messages
  end

  def set_attr
    @content_attributes = [:play_url]
    @content_attributes.concat([:recipient_detail_counts, :from_number]) unless action_name=='index'
  end
end