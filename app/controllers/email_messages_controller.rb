class EmailMessagesController < MessagesController
  include FeatureChecker
  feature :email

  wrap_parameters :message, :include => [:recipients, :subject, :body, :from_name, :open_tracking_enabled, :click_tracking_enabled], :format => :json

  protected

  def set_scope
    @message_scope = current_user.email_messages
  end

  def set_attr
    @content_attributes = [:from_name, :subject]
    @content_attributes.concat([:body, :open_tracking_enabled, :click_tracking_enabled]) unless action_name=='index'
  end
end
