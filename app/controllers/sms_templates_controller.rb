class SmsTemplatesController < TemplatesController

  wrap_parameters SmsTemplate, format: [:json, :url_encoded_form]

  private

  def template_params
    params[:sms_template]
  end

  def account_templates
    current_user.sms_templates
  end
end
