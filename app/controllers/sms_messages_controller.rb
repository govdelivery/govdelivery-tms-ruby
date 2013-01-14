class SmsMessagesController < MessagesController
  include FeatureChecker
  before_filter :set_attr
  feature :sms

  wrap_parameters :message, :include => [:body, :recipients], :format => :json

  protected

  def set_scope
    @message_scope = current_user.sms_messages
  end

  def set_attr
    @content_attribute = :short_body
  end
end