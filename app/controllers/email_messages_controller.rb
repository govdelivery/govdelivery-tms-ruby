class EmailMessagesController < MessagesController
  include FeatureChecker
  feature :email

  wrap_parameters :message,
                  include: [
                    :body,
                    :click_tracking_enabled,
                    :errors_to,
                    :from_email,
                    :from_name,
                    :macros,
                    :open_tracking_enabled,
                    :recipients,
                    :reply_to,
                    :subject
                  ],
                  format:  [:json, :url_encoded_form]

  protected

  def set_scope
    @message_scope = if action_name == 'index'
                       current_user.email_messages_indexed
                     else
                       current_user.email_messages
                     end
  end

  def set_attr
    @content_attributes = [:subject]
    @content_attributes.concat([
      :body,
      :click_tracking_enabled,
      :errors_to,
      :from_email,
      :from_name,
      :macros,
      :open_tracking_enabled,
      :reply_to
    ]) unless action_name == 'index'
  end
end
