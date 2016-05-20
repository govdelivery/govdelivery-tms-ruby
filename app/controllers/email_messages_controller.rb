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
                    :message_type_code,
                    :_links
                  ],
                  format:  [:json, :url_encoded_form]

  def create
    if params[:message][:_links].is_a?(Hash) && template_uuid = params[:message][:_links].delete(:email_template)
      params[:message][:email_template] = current_user.email_templates.find_by(uuid: template_uuid)
    end
    transform_links_payload!(params[:message])
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
      :reply_to,
      :message_type_code
    ]) unless action_name == 'index'
  end
end
