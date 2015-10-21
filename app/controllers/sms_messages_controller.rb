class SmsMessagesController < MessagesController
  include FeatureChecker
  feature :sms

  wrap_parameters :message, include: [:body, :recipients, :_links], format: [:json, :url_encoded_form]

  def create
    transform_links_payload!(params[:message])
    if params[:message] && template_id = params[:message].delete(:sms_template_id)
      params[:message][:sms_template] = current_user.sms_templates.find_by_id(template_id)
    end
    super
  end

  protected

  def set_scope
    @message_scope = current_user.sms_messages
  end

  def set_attr
    @content_attributes = [:body]
  end
end
