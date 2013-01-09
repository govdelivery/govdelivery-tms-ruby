class SmsMessagesController < MessagesController
  before_filter :set_attr

  protected

  def set_scope
    @message_scope = current_user.sms_messages
  end

  def set_attr
    @content_attribute = :short_body
  end
end