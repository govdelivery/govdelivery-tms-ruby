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

  def create
    transform_links_payload!
    if params[:email_template_id] 
      email_template = current_user.email_templates.find(params[:email_template_id])
      @message_scope = email_template.email_messages
      params[:message].reverse_merge!(email_template.attributes.to_options.select {|k,v| [:body, :subject, :link_tracking_parameters, :macros, :open_tracking_enabled, :click_tracking_enabled].include?(k)})
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
