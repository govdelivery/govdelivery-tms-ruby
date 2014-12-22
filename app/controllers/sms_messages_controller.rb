class SmsMessagesController < MessagesController
  include FeatureChecker
  feature :sms

  wrap_parameters :message, include: [:body, :recipients], format: [:json, :url_encoded_form]

  protected

  def set_scope
    @message_scope = current_user.sms_messages
  end

  def set_attr
    @content_attributes = [:body]
  end
end