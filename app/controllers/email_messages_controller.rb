class EmailMessagesController < MessagesController
  include FeatureChecker
  feature :email

  wrap_parameters :message, :include => [:recipients, :subject, :body], :format => :json

  #def create
  #  #OdmWorker.perform_async(:email=>params[:email], :account_id=>@account.id)
  #end

  protected

  def set_scope
    @message_scope = current_user.email_messages
  end

  def set_attr
    @content_attribute = :subject
  end
end
