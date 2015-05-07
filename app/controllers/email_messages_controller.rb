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
                    :subject,
                    :_links
                  ],
                  format:  [:json, :url_encoded_form]

  def create
    transform_links_payload!(params[:message])
    if params[:message] && template_id = params[:message].delete(:email_template_id)
      params[:message][:email_template] = current_user.email_templates.find_by_id(template_id)
    end
    super
  end

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
