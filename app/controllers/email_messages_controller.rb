class EmailMessagesController < MessagesController
  include FeatureChecker
  feature :email

  wrap_parameters :message, :include => [
      :body, 
      :click_tracking_enabled, 
      :from_email,
      :from_name,
      :macros,
      :open_tracking_enabled, 
      :recipients, 
      :subject, 
    ], 
    :format => :json

  protected

  def set_scope
    @message_scope = current_user.email_messages
  end

  def set_attr
    @content_attributes = [:from_name, :from_email, :subject, :macros]
    @content_attributes.concat([:body, :open_tracking_enabled, :click_tracking_enabled]) unless action_name=='index'
  end
end
