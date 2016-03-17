class SmsMessagesController < MessagesController
  include FeatureChecker
  feature :sms

  wrap_parameters :message, include: [:body, :recipients, :_links], format: [:json, :url_encoded_form]

  def create
    if params[:message][:_links].is_a?(Hash) && template_uuid = params[:message][:_links].delete(:sms_template)
      params[:message][:sms_template] = current_user.sms_templates.find_by(uuid: template_uuid)
    end
    transform_links_payload!(params[:message])
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
