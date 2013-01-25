class EmailMessagesController < MessagesController
  include FeatureChecker
  feature :email

  wrap_parameters :message, :include => [:recipients, :subject, :body], :format => :json

  protected

  def set_scope
    @message_scope = current_user.email_messages
  end

  def set_attr
    @content_attributes = [:subject, :from_name]
    @content_attributes << :body unless action_name=='index'
  end
end
